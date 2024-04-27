import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/enum/main_menu_action.dart';

import 'package:flutter_foundamentals/services/auth/auth_service.dart';
import 'package:flutter_foundamentals/services/crud/notes.service.dart';
import 'package:flutter_foundamentals/services/crud/user.service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _noteService;
  late final UserService _userService;
  String get userEmail => AuthService.firebase().currentUser!.email!;

  @override
  void initState() {
    _userService = UserService();
    _noteService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("My notes"),
          // Options for a menu on the top bar
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(newNoteRoute);
                },
                icon: const Icon(Icons.add)),
            PopupMenuButton<MainMenuAction>(
                onSelected: (value) async {
                  switch (value) {
                    case MainMenuAction.logout:
                      final shouldLogOut = await showLogOutDialog(context);
                      if (shouldLogOut) {
                        await AuthService.firebase().logOut();
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            loginRoute, (route) => false);
                      }
                    case MainMenuAction.newNote:
                      Navigator.of(context).pushNamed(newNoteRoute);
                  }
                },
                itemBuilder: (context) => [
                      const PopupMenuItem<MainMenuAction>(
                          value: MainMenuAction.newNote,
                          child: Text("New Note")),
                      const PopupMenuItem<MainMenuAction>(
                          value: MainMenuAction.logout, child: Text("Log-Out")),
                    ])
          ],
        ),
        body: FutureBuilder(
            future: _userService.getOrCreateUser(email: userEmail),
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.active:
                case ConnectionState.waiting:
                  return const Text("getOrCreateUser::none/active/waiting");

                case ConnectionState.done:
                  return StreamBuilder(
                      stream: _noteService.allNotes,
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return const Text("builder::switch::none");

                          case ConnectionState.waiting:
                          case ConnectionState.active:
                            if (snapshot.hasData) {
                              final dataNotes =
                                  snapshot.data as List<DatabaseNote>;

                              if (dataNotes.isEmpty) {
                                return const Text("No notes to show yet.");
                              }

                              return ListView.builder(
                                itemCount: dataNotes.length,
                                itemBuilder: (context, index) {
                                  final noteItem = dataNotes[index];
                                  return ListTile(
                                    title: Text(
                                      "${noteItem.text}",
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                },
                              );
                            } else {
                              return const Text("No notes to show");
                            }

                          case ConnectionState.done:
                            return const Text("builder::switch::done");
                          default:
                            return const CircularProgressIndicator();
                        }
                      });

                default:
                  return const CircularProgressIndicator();
              }
            }));
  }
}

Future<bool> showLogOutDialog(BuildContext context) {
  return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Log Out"),
          content: const Text("Are you sure you want to //log out?"),
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
