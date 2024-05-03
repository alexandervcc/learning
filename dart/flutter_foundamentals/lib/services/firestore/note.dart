import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_foundamentals/services/firestore/constants.dart';

@immutable
class FirestoreNote {
  final String id;
  final String userId;
  final String text;

  const FirestoreNote({
    required this.id,
    required this.text,
    required this.userId,
  });

  FirestoreNote.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> snapshot)
      : id = snapshot.id,
        userId = snapshot.data()[ownerUserIdColumn],
        text = snapshot.data()[textColumn];
}
