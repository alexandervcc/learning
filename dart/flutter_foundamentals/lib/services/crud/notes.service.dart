import "dart:async";

import "package:flutter_foundamentals/services/auth/auth_exception.dart";
import "package:flutter_foundamentals/services/crud/db.service.dart";
import "package:flutter_foundamentals/services/crud/exceptions.dart";
import "package:flutter_foundamentals/services/crud/user.service.dart";

class NotesService extends DatabaseConnectionService {
  final UserService _userService;
  List<DatabaseNote> _notes = [];
  late final StreamController<List<DatabaseNote>> _streamController;
  Stream<List<DatabaseNote>> get allNotes => _streamController.stream;

  NotesService._privateConstructor(this._userService) {
    _streamController =
        StreamController<List<DatabaseNote>>.broadcast(onListen: () {
      _streamController.sink.add(_notes);
    });
  }

  static final NotesService _instance =
      NotesService._privateConstructor(UserService());

  factory NotesService() => _instance;

  Future<void> cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _streamController.add(_notes);
  }

  Future<void> openDbConnection() async {
    await open();
    await cacheNotes();
  }

  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    await ensureDbIsOpen();
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
    }

    final updatedNote = await getNote(id: note.id);
    _notes.removeWhere((element) => element.id == updatedNote.id);
    _notes.add(updatedNote);
    _streamController.add(_notes);

    return updatedNote;
  }

  Future<Iterable<DatabaseNote>> getAllNotes() async {
    await ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    final notesMapped = notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
    return notesMapped;
  }

  Future<DatabaseNote> getNote({required int id}) async {
    await ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNoteException();
    }

    final note = DatabaseNote.fromRow(notes.first);

    _notes.removeWhere((element) => element.id == note.id);
    _notes.add(note);
    _streamController.add(_notes);

    return note;
  }

  Future<int> deleteAllNotes() async {
    await ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(noteTable);

    // stream update
    _notes = [];
    _streamController.add(_notes);

    return numberOfDeletions;
  }

  Future<void> deleteNote({required int id}) async {
    await ensureDbIsOpen();
    final db = getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deletedCount == 0) {
      throw CouldNotDeleteNoteException();
    }

    // stream update
    _notes.removeWhere((element) => element.id == id);
    _streamController.add(_notes);
  }

  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    await ensureDbIsOpen();
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

    // update stream
    _notes.add(note);
    _streamController.add(_notes);

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
