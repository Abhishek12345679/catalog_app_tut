import 'package:catalog_app_tut/services/auth/auth_user.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
abstract class AuthState {
  const AuthState();
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized();
}

class AuthStateLoggingIn extends AuthState {
  final Exception? exception;
  const AuthStateLoggingIn(this.exception);
}

class AuthStateRegistering extends AuthState {
  final Exception? exception;
  const AuthStateRegistering(this.exception);
}

class AuthStateLoggedIn extends AuthState {
  final AuthUser currentUser;
  const AuthStateLoggedIn(this.currentUser);
}

class AuthStateNeedsVerification extends AuthState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthState {
  final Exception? exception;
  final bool isLoading;

  const AuthStateLoggedOut({
    required this.exception,
    required this.isLoading,
  });
}
