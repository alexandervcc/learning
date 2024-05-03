import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/dialogs/cannot_share_note_dialog.dart';
import 'package:flutter_foundamentals/services/auth/auth_service.dart';
import 'package:flutter_foundamentals/services/auth/auth_user.dart';
// import 'package:flutter_foundamentals/services/crud/notes.service.dart';
// import 'package:flutter_foundamentals/services/crud/user.service.dart';
import 'package:flutter_foundamentals/services/firestore/firestore_storage.service.dart';
import 'package:flutter_foundamentals/services/firestore/note.dart';
import 'package:flutter_foundamentals/utils/get_argument.dart';
import 'package:share_plus/share_plus.dart';

class CUNoteView extends StatefulWidget {
  const CUNoteView({super.key});

  @override
  State<CUNoteView> createState() => _CUNoteViewState();
}

class _CUNoteViewState extends State<CUNoteView> {
  FirestoreNote? _note;
  late final FirestoreStorageService _firestoreNotesService;
  late final AuthUser _authUser;
  late final TextEditingController _textController;

  @override
  void initState() {
    _firestoreNotesService = FirestoreStorageService();
    _authUser = AuthService.firebase().currentUser!;
    _textController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    log("new_note::dispose");
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
    super.dispose();
  }

  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }

    await _firestoreNotesService.updateNote(
        id: note.id, text: _textController.text);
  }

  void _setUpTextControllerListener() {
    _textController.removeListener(_textControllerListener);
    _textController.addListener(_textControllerListener);
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textController.text.isEmpty && note != null) {
      await _firestoreNotesService.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    if (_textController.text.isNotEmpty && note != null) {
      _firestoreNotesService.updateNote(
        id: note.id,
        text: _textController.text,
      );
    }
  }

  Future<FirestoreNote> _createOrGetExistingNote(BuildContext context) async {
    final widgetNote = context.getArgument<FirestoreNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null) {
      return existingNote;
    }

    final newNote =
        await _firestoreNotesService.createNewNote(userId: _authUser.id);
    _note = newNote;
    return newNote;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("New note"),
          actions: [
            IconButton(
                onPressed: () async {
                  final text = _textController.text;
                  if (_note == null || text.isEmpty) {
                    await showCannotShareDialog(context);
                    return;
                  }
                  Share.share(text);
                },
                icon: const Icon(Icons.share))
          ],
        ),
        body: FutureBuilder(
          future: _createOrGetExistingNote(context),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              // TODO: Handle this case.
              case ConnectionState.waiting:
              // TODO: Handle this case.
              case ConnectionState.active:
              // TODO: Handle this case.
              case ConnectionState.done:
                _setUpTextControllerListener();
                return TextField(
                  controller: _textController,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration:
                      const InputDecoration(hintText: "Start typing your note"),
                );
              default:
                return const CircularProgressIndicator();
            }
          },
        ));
  }
}
