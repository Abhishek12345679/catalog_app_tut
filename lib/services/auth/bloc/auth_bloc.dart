import 'dart:developer';

import 'package:catalog_app_tut/services/auth/auth_provider.dart';
import 'package:catalog_app_tut/services/auth/bloc/event/auth_event.dart';
import 'package:catalog_app_tut/services/auth/bloc/state/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider)
      : super(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        )) {
    on<AuthEventInit>((_, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user != null) {
        if (!user.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
        } else {
          emit(AuthStateLoggedIn(user));
        }
      }
    });

    on<AuthEventLogIn>((event, emit) async {
      try {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: true,
          ),
        );
        await provider
            .logIn(
          email: event.email,
          password: event.password,
        )
            .then((user) {
          if (user.isEmailVerified) {
            emit(const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ));
            emit(AuthStateLoggedIn(user));
          } else {
            log('unverified');
            emit(const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ));
            emit(const AuthStateNeedsVerification());
          }
        });
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventLogout>((event, emit) async {
      try {
        await provider.logOut();
        emit(const AuthStateLoggedOut(
          exception: null,
          isLoading: false,
        ));
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(
          exception: e,
          isLoading: false,
        ));
      }
    });

    on<AuthEventRegister>((event, emit) async {
      try {
        await provider.createUser(
          email: event.email,
          password: event.password,
        );
        await provider.sendVerificationEmail();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    on<AuthEventSendVerificationEmail>((event, emit) async {
      await provider.sendVerificationEmail();
      emit(state);
    });

    on<AuthEventShouldRegister>((event, emit) {});
  }
}
