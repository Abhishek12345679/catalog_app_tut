import 'package:catalog_app_tut/views/email_verification_view.dart';
import 'package:catalog_app_tut/views/login_view.dart';
import 'package:catalog_app_tut/views/main_notes_view.dart';
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
        if (snapshot.hasData) {
          if (snapshot.data?.emailVerified ?? false) {
            return MainNotesView(
              email: snapshot.data?.email,
            );
          } else {
            return const EmailVerificationView();
          }
        } else {
          return const LoginView();
        }
      },
    );
  }
}
