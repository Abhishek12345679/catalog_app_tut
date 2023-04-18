import 'package:catalog_app_tut/services/auth/auth_provider.dart';
import 'package:catalog_app_tut/services/auth/auth_user.dart';
import 'package:catalog_app_tut/services/auth/bloc/event/auth_event.dart';
import 'package:catalog_app_tut/services/auth/bloc/state/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    on<AuthEventInit>((_, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoading());
      try {
        final user = await provider.logIn(
          email: event.email,
          password: event.password,
        );
        emit(AuthStateLoggedIn(user));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });

    on<AuthEventLogout>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });

    on<AuthEventAuthChange>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        final firebaseUserStream = provider.authChange();

        final user = await firebaseUserStream.first;
        if (user == null) {
          emit(const AuthStateLoggedOut());
        } else if (!user.emailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          final authUser = AuthUser.fromFirebase(user);
          emit(AuthStateLoggedIn(authUser));
        }
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });
  }
}
