import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/services/crud/notes.service.dart';
import 'package:flutter_foundamentals/utils/delete_dialog.dart';

typedef DeleteNoteCallback = void Function(DatabaseNote note);

class NotesListView extends StatelessWidget {
  const NotesListView({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  final List<DatabaseNote> notes;
  final DeleteNoteCallback onDeleteNote;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final noteItem = notes[index];
        return ListTile(
          title: Text(
            "${noteItem.text}",
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
