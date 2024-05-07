import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/enum/main_menu_action.dart';

import 'package:flutter_foundamentals/services/auth/auth_service.dart';
import 'package:flutter_foundamentals/dialogs/logout_dialog.dart';
import 'package:flutter_foundamentals/services/firestore/firestore_storage.service.dart';
import 'package:flutter_foundamentals/services/firestore/note.dart';
import 'package:flutter_foundamentals/views/notes_list_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final FirestoreStorageService _firestoreNoteService;
  String get userEmail => AuthService.firebase().currentUser!.email;
  String get userId => AuthService.firebase().currentUser!.id;

  @override
  void initState() {
    _firestoreNoteService = FirestoreStorageService();
    log("->notes_view::initState::userId: $userId");
    _firestoreNoteService.getNotes(userId: userId);
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
                Navigator.of(context).pushNamed(cuNoteRoute);
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton<MainMenuAction>(
              onSelected: (value) async {
                switch (value) {
                  case MainMenuAction.logout:
                    final shouldLogOut = await showGenericLogoutDialog(context);
                    if (shouldLogOut) {
                      await AuthService.firebase().logOut();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    }
                  case MainMenuAction.newNote:
                    Navigator.of(context).pushNamed(cuNoteRoute);
                  case MainMenuAction.blocCounter:
                    Navigator.of(context).pushNamed(counterBlocRoute);
                }
              },
              itemBuilder: (context) => [
                    const PopupMenuItem<MainMenuAction>(
                        value: MainMenuAction.newNote, child: Text("New Note")),
                    const PopupMenuItem<MainMenuAction>(
                        value: MainMenuAction.logout, child: Text("Log-Out")),
                        const PopupMenuItem<MainMenuAction>(
                        value: MainMenuAction.blocCounter, child: Text("Counter Bloc")),
                        
                  ])
        ],
      ),
      body: StreamBuilder(
          stream: _firestoreNoteService.allNotes(userId: userId),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return const Text("builder::switch::none");

              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final dataNotes = snapshot.data as Iterable<FirestoreNote>;

                  if (dataNotes.isEmpty) {
                    return const Text("No notes to show yet.");
                  }

                  return NotesListView(
                    notes: dataNotes,
                    onDeleteNote: (note) async {
                      await _firestoreNoteService.deleteNote(id: note.id);
                    },
                    onTap: (note) {
                      Navigator.of(context).pushNamed(
                        cuNoteRoute,
                        arguments: note,
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
          }),
    );
  }
}
