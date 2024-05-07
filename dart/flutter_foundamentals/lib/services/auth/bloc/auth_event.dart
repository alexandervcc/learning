import 'package:flutter/foundation.dart';

@immutable
abstract class AuthBlocEvent {
  const AuthBlocEvent();
}

class AuthEventInitialize extends AuthBlocEvent {
  const AuthEventInitialize();
}

class AuthEventLogIn extends AuthBlocEvent {
  final String email;
  final String password;

  const AuthEventLogIn({
    required this.email,
    required this.password,
  });
}

class AuthEventLogOut extends AuthBlocEvent {
  const AuthEventLogOut();
}
