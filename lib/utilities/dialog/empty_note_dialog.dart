import 'package:catalog_app_tut/utilities/dialog/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: "Empty Note",
    content: "Please type something to be able to share this note.",
    optionBuilder: () => {
      "OK": null,
    },
  );
}
