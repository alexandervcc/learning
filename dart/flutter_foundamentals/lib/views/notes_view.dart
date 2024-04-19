import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/enum/main_menu_action.dart';
import 'dart:developer' show log;

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My notes"),
        // Options for a menu on the top bar
        actions: [
          PopupMenuButton<MainMenuAction>(
              onSelected: (value) async {
                log("Selected menu item: ${value.name} ");
                switch (value) {
                  case MainMenuAction.logout:
                    final shouldLogOut = await showLogOutDialog(context);
                    log("User should be logged out: $shouldLogOut");
                    if (shouldLogOut) {
                      await FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                }
              },
              itemBuilder: (context) => [
                    const PopupMenuItem<MainMenuAction>(
                        value: MainMenuAction.logout, child: Text("Log-Out"))
                  ])
        ],
      ),
    );
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
                onPressed: () {
                  log("User did not log out");
                  Navigator.of(context).pop(false);
                },
                child: const Text("Cancel")),
            TextButton(
                onPressed: () {
                  log("User logged out");
                  Navigator.of(context).pop(true);
                },
                child: const Text("Log-Out")),
          ],
        );
      }).then((value) => value ?? false);
}
