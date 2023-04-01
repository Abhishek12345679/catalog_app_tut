// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:catalog_app_tut/services/auth/auth_provider.dart';
import 'package:catalog_app_tut/services/auth/auth_user.dart';

class AuthService implements AuthProvider {
  final AuthProvider provider;
  AuthService({
    required this.provider,
  });

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) {
    return provider.createUser(
      email: email,
      password: password,
    );
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) {
    return provider.logIn(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logOut() {
    return provider.logOut();
  }

  @override
  Future<void> sendVerificationEmail() {
    return provider.sendVerificationEmail();
  }
}
