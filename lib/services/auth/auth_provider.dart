import 'package:catalog_app_tut/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;

  Future<void> initialize();

  Stream<User?> authChange();

  Future<AuthUser> logIn({
    required String email,
    required String password,
  });
  Future<AuthUser> createUser({
    required String email,
    required String password,
  });

  Future<void> logOut();
  Future<void> sendVerificationEmail();
}
