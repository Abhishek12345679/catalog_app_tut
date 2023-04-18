import 'dart:developer';

import 'package:catalog_app_tut/services/auth/bloc/auth_bloc.dart';
import 'package:catalog_app_tut/services/auth/bloc/event/auth_event.dart';
import 'package:catalog_app_tut/services/auth/bloc/state/auth_state.dart';
import 'package:catalog_app_tut/views/email_verification_view.dart';
import 'package:catalog_app_tut/views/login_view.dart';
import 'package:catalog_app_tut/views/notes/main_notes_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        context.read<AuthBloc>().add(
              const AuthEventInit(),
            );
        if (state is AuthStateLoggedIn) {
          return const MainNotesView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateNeedsVerification) {
          return const EmailVerificationView();
        } else {
          return const Scaffold(
            body: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
