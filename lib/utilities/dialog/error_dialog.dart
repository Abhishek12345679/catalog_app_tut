import 'package:catalog_app_tut/utilities/dialog/generic_dialog.dart';
import 'package:flutter/material.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: "An Error Occured",
    content: text,
    optionBuilder: () => {"OK": null},
  );
}
