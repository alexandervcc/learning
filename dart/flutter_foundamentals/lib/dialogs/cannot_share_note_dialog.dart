import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/dialogs/generic_dialog.dart';

Future<void> showCannotShareDialog(BuildContext context) async {
  return showGenericDialog(
    context: context,
    title: "Cannot share note",
    content: "Your note is empty.",
    optionBuilder: () => {
      "Ok": null,
    },
  );
}
