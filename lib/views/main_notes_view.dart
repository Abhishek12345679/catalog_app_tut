import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainNotesView extends StatelessWidget {
  final String? email;

  const MainNotesView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Column(
        children: [
          Center(child: Text('Logged in as $email')),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Logout'),
          )
        ],
      ),
    );
  }
}
