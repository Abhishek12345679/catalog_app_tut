import 'dart:developer';

import 'package:catalog_app_tut/utilities/show_error_dialog.dart';
import 'package:catalog_app_tut/views/main_notes_view.dart';
import 'package:catalog_app_tut/views/register_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
              TextButton(
                onPressed: () async {
                  try {
                    final userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _email.text,
                      password: _password.text,
                    );
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MainNotesView(email: _email.text),
                        ),
                        (route) => false,
                      );
                    }
                    log(userCredential.toString());
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      await showErrorDialog(context, "User Not Found");
                    } else if (e.code == 'invalid-email') {
                      await showErrorDialog(
                          context, "Enter a valid Email Address");
                    } else if (e.code == 'wrong-password') {
                      await showErrorDialog(
                          context, "You have entered the wrong password");
                    } else {
                      await showErrorDialog(context, e.message!);
                    }
                  } catch (e) {
                    await showErrorDialog(context, e.toString());
                  }
                },
                child: const Text('Login'),
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
