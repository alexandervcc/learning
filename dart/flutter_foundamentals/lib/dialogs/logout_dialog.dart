import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/dialogs/generic_dialog.dart';

const logOutTitle = "Log Out";
const logOutContent = "Are you sure you want to log out?";

/// Old logout dialog
@Deprecated('Use [showGenericLogoutDialog]')
Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(logOutTitle),
          content: const Text(logOutContent),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log-Out")),
          ],
        );
      }).then((value) => value ?? false);
}

Future<bool> showGenericLogoutDialog(BuildContext context) {
  return showGenericDialog<bool>(
          context: context,
          title: logOutTitle,
          content: logOutContent,
          optionBuilder: () => {"Cancel": false, "Log out": true})
      .then((value) => value ?? false);
}
