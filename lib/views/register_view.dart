import 'package:catalog_app_tut/services/auth/auth_exceptions.dart';
import 'package:catalog_app_tut/services/auth/bloc/event/auth_event.dart';
import 'package:catalog_app_tut/services/auth/bloc/state/auth_state.dart';
import 'package:catalog_app_tut/utilities/dialog/error_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/auth/bloc/auth_bloc.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
              context,
              "Weak Password!",
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context,
              "User with this email, already exists!",
            );
          } else if (state.exception is UserNotLoggedInException) {
            await showErrorDialog(
              context,
              "You have to login first!",
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              "Invalid Email!",
            );
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              state.exception.toString(),
            );
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Column(
              children: [
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  autocorrect: false,
                  enableSuggestions: false,
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  autocorrect: false,
                  enableSuggestions: false,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: TextButton(
                    onPressed: () {
                      context.read<AuthBloc>().add(
                            AuthEventRegister(
                              email: _email.text,
                              password: _password.text,
                            ),
                          );
                      context
                          .read<AuthBloc>()
                          .add(const AuthEventSendVerificationEmail());
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.black),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => Colors.white),
                    ),
                    child: const Text('Register'),
                  ),
                ),
                TextButton(
                  child: const Text('Already have an Account? Login'),
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogout());
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
