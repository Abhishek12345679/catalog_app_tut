import 'dart:developer';

import 'package:catalog_app_tut/services/auth/auth_exceptions.dart';
import 'package:catalog_app_tut/services/auth/bloc/auth_bloc.dart';
import 'package:catalog_app_tut/services/auth/bloc/event/auth_event.dart';
import 'package:catalog_app_tut/services/auth/bloc/state/auth_state.dart';
import 'package:catalog_app_tut/utilities/dialog/error_dialog.dart';
import 'package:catalog_app_tut/views/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool isLoggingIn = false;

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
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
              BlocListener<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is AuthStateLoggedOut) {
                    setState(() {
                      isLoggingIn = false;
                    });
                    if (state.exception is UserNotFoundAuthException) {
                      await showErrorDialog(
                        context,
                        "User Not Found",
                      );
                    } else if (state.exception is InvalidEmailAuthException) {
                      await showErrorDialog(
                        context,
                        "Enter a valid Email Address",
                      );
                    } else if (state.exception is WrongPasswordAuthException) {
                      await showErrorDialog(
                        context,
                        "You have entered the wrong password.",
                      );
                    } else if (state.exception is GenericAuthException) {
                      await showErrorDialog(
                        context,
                        state.exception.toString(),
                      );
                    }
                  } else if (state is AuthStateLoading) {
                    setState(() {
                      isLoggingIn = true;
                    });
                    // log('loading');
                  } else if (state is AuthStateLoggedIn) {
                    setState(() {
                      isLoggingIn = false;
                    });
                  }
                },
                child: ElevatedButton(
                  onPressed: () async {
                    context.read<AuthBloc>().add(
                          AuthEventLogIn(
                            email: _email.text,
                            password: _password.text,
                          ),
                        );
                  },
                  child: isLoggingIn
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Login'),
                ),
              ),
              TextButton(
                autofocus: true,
                child: const Text('Create New Account'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterView(),
                    ),
                    (route) => false,
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
