import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/dialogs/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog<bool>(
          context: context,
          title: "Delete confirmation",
          content: "You sure you wanna delete?",
          optionBuilder: () => {"Cancel": false, "Delete": true})
      .then((value) => value ?? false);
}
