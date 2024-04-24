import "package:flutter_foundamentals/services/auth/auth_exception.dart";
import "package:flutter_foundamentals/services/crud/db.service.dart";
import "package:flutter_foundamentals/services/crud/exceptions.dart";
import "package:flutter_foundamentals/services/crud/user.service.dart";

class NotesService extends DatabaseConnectionService {
  final UserService _userService;

  NotesService(this._userService);

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = getDatabaseOrThrow();

    await getNote(id: note.id);

    final updatesCount = await db.update(
      noteTable,
      {
        columnText: text,
        columnIsCloudSynced: 0,
      },
      where: 'id = ?',
      whereArgs: [note.id],
    );

    if (updatesCount == 0) {
      throw CouldNotUpdateNoteException();
    } else {
      final updatedNote = await getNote(id: note.id);
      return updatedNote;
    }
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = getDatabaseOrThrow();
    final notes = await db.query(noteTable);

    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
  }

  Future<DatabaseNote> getNote({required int id}) async {
    final db = getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    } else {
      final note = DatabaseNote.fromRow(notes.first);
      return note;
    }
  }

  Future<int> deleteAllNotes() async {
    final db = getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    final db = getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = getDatabaseOrThrow();

    final dbUser = await _userService.getUser(email: owner.email);
    if (dbUser != owner) {
      throw UserNotFoundException();
    }

    const text = '';
    final noteId = await db.insert(noteTable, {
      columnUserId: owner.id,
      columnText: text,
      columnIsCloudSynced: 1,
    });

    final note = DatabaseNote(
      id: noteId,
      userId: owner.id,
      text: text,
      isCloudSynced: true,
    );

    return note;
  }
}

class DatabaseNote {
  final int id;
  final String? text;
  final int userId;
  final bool isCloudSynced;

  DatabaseNote({
    required this.id,
    required this.userId,
    required this.isCloudSynced,
    required this.text,
  });

  DatabaseNote.fromRow(Map<String, Object?> map)
      : id = map[columnId] as int,
        text = map[columnText] as String,
        isCloudSynced = (map[columnIsCloudSynced] as int) == 1 ? true : false,
        userId = map[columnUserId] as int;

  @override
  String toString() =>
      "Note, ID = $id, user = $userId, isCloudSynced = $isCloudSynced, text = $text";

  @override
  bool operator ==(covariant DatabaseUser other) => other.id == id;

  @override
  int get hashCode => id.hashCode;
}

const columnId = "id";
const columnUserId = "user_id";
const columnText = "text";
const columnIsCloudSynced = "is_cloud_synced";
