import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/dialogs/generic_dialog.dart';

/// Old error dialog
@Deprecated('Use [genericErrorDialog]')
Future<void> showErrorDialog(BuildContext context, String text) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("An error occurred"),
        content: Text(text),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'))
        ],
      );
    },
  );
}

Future<void> showGenericErrorDialog(BuildContext context, String text) {
  return showGenericDialog<void>(
      context: context,
      title: "An error occurred",
      content: text,
      optionBuilder: () => {'OK': null});
}
