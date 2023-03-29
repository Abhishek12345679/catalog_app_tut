import 'package:catalog_app_tut/views/login_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter the Verification Code to continue.',
            ),
            // TextField(
            //   decoration: InputDecoration(hintText: 'Verification Code'),
            // ),
            TextButton(
              child: const Text('Send Verification Code'),
              onPressed: () async {
                final currentUser = FirebaseAuth.instance.currentUser;
                print(currentUser);
                currentUser?.sendEmailVerification();
              },
            ),
          ],
        ),
      ),
    );
  }
}
