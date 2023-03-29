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

  late String? loginValidationMessage;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    loginValidationMessage = null;
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
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  loginValidationMessage ?? "",
                  style: const TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    final userCredential =
                        await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: _email.text,
                      password: _password.text,
                    );
                    setState(() {
                      loginValidationMessage = '';
                    });
                    // print('user: $userCredential');
                  } on FirebaseAuthException catch (e) {
                    // print('error: ${e.code}');
                    setState(() {
                      loginValidationMessage = e.message;
                    });
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
