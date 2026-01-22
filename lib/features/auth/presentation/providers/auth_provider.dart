import 'package:flutter/material.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/errors/auth_exceptions.dart';

enum AuthStatus { unknown, authenticated, unauthenticated, guest }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  UserEntity? _user;
  AuthStatus _status = AuthStatus.unknown;

  // Pending credential for account linking
  dynamic _pendingCredential;
  String? _pendingEmail;

  AuthProvider(this._authRepository) {
    _init();
  }

  UserEntity? get user => _user;
  AuthStatus get status => _status;
  String? get pendingEmail => _pendingEmail;

  bool _isSplashDone = false;
  bool _isAuthLoaded = false;

  void _init() {
    // 1. Start the minimum splash display timer (e.g., 2 seconds)
    Future.delayed(const Duration(seconds: 2), () {
      _isSplashDone = true;
      _updateStatus();
    });

    // 2. Listen to the repository auth changes
    _authRepository.authStateChanges.listen((UserEntity? user) {
      _user = user;
      _isAuthLoaded = true;
      _updateStatus();
    });
  }

  void _updateStatus() {
    // Only update the public status if BOTH splash is done AND we have real auth data
    if (!_isSplashDone || !_isAuthLoaded) {
      return;
    }

    if (_user == null) {
      _status = AuthStatus.unauthenticated;
    } else if (_user!.isGuest) {
      _status = AuthStatus.guest;
    } else {
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);

      // Check if we have a pending credential to link (Amazon-style linking)
      if (_pendingCredential != null) {
        try {
          await _authRepository.linkCredential(_pendingCredential);
        } catch (e) {
          // If linking fails, we are still logged in, which is fine mostly.
          // Maybe log it or notify user. For now, we clear the pending cred.
          // print("Linking failed: $e"); // Log silently or ignore
        } finally {
          _pendingCredential = null;
          _pendingEmail = null;
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      await _authRepository.registerWithEmailAndPassword(email, password, name);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      await _authRepository.signInWithGoogle();
    } on AccountExistsWithDifferentCredentialException catch (e) {
      _pendingCredential = e.credential;
      _pendingEmail = e.email;
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> enterGuestMode() async {
    try {
      await _authRepository.signInAnonymously();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authRepository.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  List<String> get linkedProviders => _authRepository.getLinkedProviders();

  Future<void> changePassword(String newPassword) async {
    try {
      await _authRepository.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      await _authRepository.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    _pendingCredential = null;
    _pendingEmail = null;
    await _authRepository.signOut();
  }
}
