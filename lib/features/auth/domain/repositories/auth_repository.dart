import '../entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  Future<UserEntity> signInWithEmailAndPassword(String email, String password);
  Future<UserEntity> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  );
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> linkCredential(dynamic credential);
  Future<UserEntity> signInAnonymously();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> signOut();
  List<String> getLinkedProviders();
  Future<void> updatePassword(String newPassword);
  Future<void> updateProfile({String? displayName, String? photoUrl});
}
