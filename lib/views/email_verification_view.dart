import 'package:catalog_app_tut/services/auth/auth_service.dart';
import 'package:catalog_app_tut/views/register_view.dart';
import 'package:flutter/material.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({
    super.key,
  });

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
              'We have sent you a verification email. Please click on the link in the email to verify yourself.',
            ),
            const Text(
              'If you have not recieved the verification email, please press the button below.',
            ),
            TextButton(
              child: const Text('Send Verification Code'),
              onPressed: () async {
                await AuthService.firebase().sendVerificationEmail();
              },
            ),
            TextButton(
              child: const Text('Restart'),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterView(),
                  ),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
