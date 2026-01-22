import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/auth_exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FlutterSecureStorage _storage;
  final StreamController<UserEntity?> _authStateController =
      StreamController<UserEntity?>.broadcast();

  static const String _guestKey = 'is_guest_mode';

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FlutterSecureStorage? storage,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn(),
       _storage = storage ?? const FlutterSecureStorage() {
    _init();
  }

  void _init() async {
    // Check if guest mode is active
    final isGuestStr = await _storage.read(key: _guestKey);
    final isGuest = isGuestStr == 'true';

    if (isGuest) {
      _authStateController.add(UserEntity.guest);
    }

    // Listen to Firebase auth state
    _firebaseAuth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        // If Firebase sends a user, we are definitely authenticated via Firebase
        // This overrides guest mode (e.g. if I was guest and then logged in)
        if (isGuest) {
          _storage.delete(key: _guestKey);
        }
        _authStateController.add(_mapFirebaseUser(firebaseUser));
      } else {
        // Firebase sees no user. Check if we are in guest mode.
        // We re-read storage or use cached value?
        // Better to re-read or manage state carefully.
        // For simplicity here, we rely on the implementation methods to update local state
        // but for initial load/listener, we need to be careful.
        // If we are listening, and firebase emits null, we should check storage.
        _checkGuestStatus();
      }
    });
  }

  Future<void> _checkGuestStatus() async {
    final isGuestStr = await _storage.read(key: _guestKey);
    if (isGuestStr == 'true') {
      _authStateController.add(UserEntity.guest);
    } else {
      _authStateController.add(null);
    }
  }

  UserEntity? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      isGuest: false,
    );
  }

  @override
  Stream<UserEntity?> get authStateChanges => _authStateController.stream;

  @override
  UserEntity? get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      return _mapFirebaseUser(user);
    }
    // We can't synchronously check secure storage for guest.
    // So 'currentUser' synchronous getter is tricky for Guest.
    // We might need to rely on the stream or store a local cache.
    // For now, return null if no firebase user, consumers should use stream.
    return null;
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _storage.delete(key: _guestKey);
    return _mapFirebaseUser(credential.user!)!;
  }

  @override
  Future<UserEntity> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(name);
      await credential.user!.reload();
      final updatedUser = _firebaseAuth.currentUser;

      await _storage.delete(key: _guestKey);
      return _mapFirebaseUser(updatedUser!)!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception(
          'This email is already registered. Please sign in instead.',
        );
      }
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Google Sign In aborted');
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      await _storage.delete(key: _guestKey);
      return _mapFirebaseUser(userCredential.user!)!;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'account-exists-with-different-credential') {
        throw AccountExistsWithDifferentCredentialException(
          credential: credential,
          email: googleUser.email,
        );
      }
      rethrow;
    }
  }

  @override
  Future<UserEntity> linkCredential(dynamic credential) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('No user signed in to link credential');
    }

    final userCredential = await user.linkWithCredential(
      credential as AuthCredential,
    );
    return _mapFirebaseUser(userCredential.user!)!;
  }

  @override
  Future<UserEntity> signInAnonymously() async {
    // User requested Guest Mode
    // We DO NOT call firebaseAuth.signInAnonymously() as per requirements "No Firebase Account"
    // We just set local flag.
    await _storage.write(key: _guestKey, value: 'true');
    _authStateController.add(UserEntity.guest);
    return UserEntity.guest;
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
    await _storage.delete(key: _guestKey);
    _authStateController.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  List<String> getLinkedProviders() {
    final user = _firebaseAuth.currentUser;
    if (user == null) return [];
    return user.providerData.map((e) => e.providerId).toList();
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) throw Exception('No user signed in');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }
    if (photoUrl != null) {
      await user.updatePhotoURL(photoUrl);
    }

    await user.reload();
    final updatedUser = _firebaseAuth.currentUser;
    _authStateController.add(_mapFirebaseUser(updatedUser));
  }
}
