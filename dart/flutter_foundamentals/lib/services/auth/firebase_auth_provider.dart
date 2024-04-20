import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuthException, FirebaseAuth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_foundamentals/firebase_options.dart';
import 'package:flutter_foundamentals/services/auth/auth_provider.dart';
import 'package:flutter_foundamentals/services/auth/auth_exception.dart';
import 'package:flutter_foundamentals/services/auth/auth_user.dart';

class FirebaseAuthProvider implements AuthProvider {
  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = currentUser;
      if (user != null) {
        return user;
      }
    } on FirebaseAuthException catch (e) {
      log("Error creating user: $e");
      if (e.code == 'weak-password') {
        throw WeakPasswordException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailInUseException();
      } else {
        GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }

    throw UserNotLoggedInException();
  }

  @override
  Future<AuthUser> logIn({
    required String email,
    required String password,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = currentUser;
      if (user != null) {
        return user;
      }
    } on FirebaseAuthException catch (e) {
      log("Error authenticating user: $e");
      if (e.code == "invalid-email") {
        throw InvalidEmailException();
      } else if (e.code == "invalid-credential") {
        GenericAuthException();
      } else {
        GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }

    throw UserNotLoggedInException();
  }

  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw UserNotLoggedInException();
    }

    await FirebaseAuth.instance.signOut();
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.sendEmailVerification();
    }

    throw UserNotLoggedInException();
  }

  @override
  Future<void> initializeApp() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}
