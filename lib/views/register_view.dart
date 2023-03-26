import 'package:catalog_app_tut/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
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
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return Center(
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
                          final userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(
                            email: _email.text,
                            password: _password.text,
                          );
                          print('user: $userCredential');
                        } on FirebaseAuthException catch (e) {}
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black),
                        foregroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white),
                      ),
                      child: const Text('Register'),
                    )
                  ],
                ),
              );
            default:
              return const Text('Loading...');
          }
        },
      ),
    );
  }
}
