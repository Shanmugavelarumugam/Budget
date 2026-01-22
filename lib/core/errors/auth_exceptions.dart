import 'package:firebase_auth/firebase_auth.dart';

class AccountExistsWithDifferentCredentialException implements Exception {
  final AuthCredential credential;
  final String? email;

  AccountExistsWithDifferentCredentialException({
    required this.credential,
    this.email,
  });

  @override
  String toString() =>
      'AccountExistsWithDifferentCredentialException: Account exists with different credential';
}
