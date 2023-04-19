import 'package:catalog_app_tut/services/auth/bloc/auth_bloc.dart';
import 'package:catalog_app_tut/services/auth/bloc/event/auth_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventShouldRegister());
              },
            ),
            TextButton(
              child: const Text('Restart'),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEventShouldRegister());
              },
            ),
          ],
        ),
      ),
    );
  }
}
