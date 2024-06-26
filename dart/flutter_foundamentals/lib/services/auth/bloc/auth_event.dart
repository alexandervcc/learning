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

class AuthEventSendEmailVerification extends AuthBlocEvent {
  const AuthEventSendEmailVerification();
}

class AuthEventRegister extends AuthBlocEvent {
  final String email;
  final String password;

  const AuthEventRegister({
    required this.email,
    required this.password,
  });
}

class AuthEventShoulRegister extends AuthBlocEvent {
  const AuthEventShoulRegister();
}

class AuthEventForgotPassword extends AuthBlocEvent {
  final String? email;

  const AuthEventForgotPassword({
    this.email
  });
}