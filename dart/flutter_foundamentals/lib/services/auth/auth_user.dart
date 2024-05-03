import "package:firebase_auth/firebase_auth.dart" show User;
import "package:flutter/foundation.dart";

@immutable
class AuthUser {
  final bool isEmailVerified;
  final String id;
  final String email;

  const AuthUser(
      {required this.isEmailVerified, required this.email, required this.id});

  // factory constructor
  factory AuthUser.fromFirebase(User user) => AuthUser(
        id: user.uid,
        email: user.email!,
        isEmailVerified: user.emailVerified,
      );
}
