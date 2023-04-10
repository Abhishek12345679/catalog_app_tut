import 'package:catalog_app_tut/utilities/dialog/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<bool> showDeleteNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Delete Note",
    content: "Are you sure you want to delete this note?",
    optionBuilder: () => {
      'Cancel': false,
      "Delete": true,
    },
  ).then(
    (value) => value ?? false,
  );
}
