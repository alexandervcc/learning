import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/dialogs/generic_dialog.dart';

Future<void> showResetPasswordDialog({required BuildContext context}) async {
  return showGenericDialog(
    context: context,
    title: "Reset password",
    content: "A password reset link was sent",
    optionBuilder: () => {
      "Ok": null,
    },
  );
}
