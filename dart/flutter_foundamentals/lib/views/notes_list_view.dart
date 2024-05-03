import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/dialogs/delete_dialog.dart';
import 'package:flutter_foundamentals/services/firestore/note.dart';

typedef NoteCallback = void Function(FirestoreNote note);

class NotesListView extends StatelessWidget {
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onTap,
  });

  final Iterable<FirestoreNote> notes;
  final NoteCallback onDeleteNote;
  final NoteCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final noteItem = notes.elementAt(index);
        return ListTile(
          onTap: () => onTap(noteItem),
          title: Text(
            noteItem.text,
            maxLines: 1,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final shouldDelete = await showDeleteDialog(context);
              if (shouldDelete) {
                onDeleteNote(noteItem);
              }
            },
          ),
        );
      },
    );
  }
}
