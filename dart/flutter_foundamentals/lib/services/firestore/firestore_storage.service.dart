import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_foundamentals/services/firestore/constants.dart';
import 'package:flutter_foundamentals/services/firestore/exceptions.dart';
import 'package:flutter_foundamentals/services/firestore/note.dart';

class FirestoreStorageService {
  // singleton constructor
  FirestoreStorageService._privateConstructor();

  static final FirestoreStorageService _instance =
      FirestoreStorageService._privateConstructor();

  factory FirestoreStorageService() => _instance;

  // methods
  Future<FirestoreNote> createNewNote({required String userId}) async {
    final document = await _notesCollection.add({
      ownerUserIdColumn: userId,
      textColumn: "",
    });
    final note = await document.get();
    return FirestoreNote(id: note.id, text: "", userId: userId);
  }

  Future<void> deleteNote({required String id}) async {
    try {
      await _notesCollection.doc(id).delete();
    } catch (e) {
      throw CouldNotDeleteNoteException();
    }
  }

  Future<void> updateNote({
    required String id,
    required String text,
  }) async {
    try {
      await _notesCollection.doc(id).update({textColumn: text});
    } catch (e) {
      throw CouldNotUpdateNoteException();
    }
  }

  Future<Iterable<FirestoreNote>> getNotes({required String userId}) async {
    try {
      final notesSnapshot = await _notesCollection
          .where(ownerUserIdColumn, isEqualTo: userId)
          .get();
      final notes =
          notesSnapshot.docs.map((fnote) => FirestoreNote.fromSnapshot(fnote));
      log("->firestore_storage::getNotes::notes: $notes");
      return notes;
    } catch (e) {
      throw CouldNotGetAllNotesException();
    }
  }

  // attributes
  final _notesCollection =
      FirebaseFirestore.instance.collection(noteCollection);

  Stream<Iterable<FirestoreNote>> allNotes({required String userId}) =>
      _notesCollection.snapshots().map((snap) => snap.docs
          .map((doc) => FirestoreNote.fromSnapshot(doc))
          .where((fnote) => fnote.userId == userId));
}
