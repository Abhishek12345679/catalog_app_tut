import 'package:catalog_app_tut/views/email_verification_view.dart';
import 'package:catalog_app_tut/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.data?.emailVerified ?? false) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Logged In'),
            ),
            body: Column(
              children: [
                Center(child: Text('Logged in as ${snapshot.data?.email}')),
                TextButton(
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                    child: const Text('Logout'))
              ],
            ),
          );
        } else {
          return EmailVerificationView();
          // Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //       builder: (context) => const EmailVerificationView(),
          //     ));
        }
      },
    );
  }
}
