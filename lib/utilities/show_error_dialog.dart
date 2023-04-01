import 'package:flutter/material.dart';

Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Login Error'),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Dismiss',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          )
        ],
      );
    },
  );
}
