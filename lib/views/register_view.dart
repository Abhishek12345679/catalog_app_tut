import 'package:catalog_app_tut/services/auth/auth_exceptions.dart';
import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/utilities/show_error_dialog.dart';
import 'package:catalog_app_tut/views/email_verification_view.dart';
import 'package:catalog_app_tut/views/login_view.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
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
                  onPressed: () async {
                    try {
                      final userCredential =
                          await AuthService.firebase().createUser(
                        email: _email.text,
                        password: _password.text,
                      );
                      await AuthService.firebase().sendVerificationEmail();

                      if (context.mounted) {
                        // The If block solves this:  Don't use 'BuildContext's across async gaps. Try rewriting the code to not reference the 'BuildContext'.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmailVerificationView(),
                          ),
                        );
                      }
                    } on EmailAlreadyInUseAuthException {
                      await showErrorDialog(
                        context,
                        "User with this email already exists",
                      );
                    } on InvalidEmailAuthException {
                      await showErrorDialog(
                        context,
                        "Enter a valid Email Address",
                      );
                    } on WeakPasswordAuthException {
                      await showErrorDialog(
                        context,
                        "Please enter a stronger password",
                      );
                    } on GenericAuthException catch (e) {
                      await showErrorDialog(
                        context,
                        e.toString(),
                      );
                    }
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
                  // To remove all the routes below the pushed route, use a RoutePredicate that always returns false (e.g. (Route<dynamic> route) => false).

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginView(),
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
