import 'package:flutter/foundation.dart';
import 'package:flutter_foundamentals/services/auth/auth_user.dart';

@immutable
abstract class AuthBlocState {
  const AuthBlocState();
}

class AuthStateLoading extends AuthBlocState {
  const AuthStateLoading();
}

class AuthStateLoggedIn extends AuthBlocState {
  final AuthUser user;

  const AuthStateLoggedIn(this.user);
}

class AuthStateLoginFailure extends AuthBlocState {
  final Exception exception;
  const AuthStateLoginFailure(this.exception);
}

class AuthStateNeedsVerification extends AuthBlocState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthBlocState {
  const AuthStateLoggedOut();
}

class AuthStateLogoutFailure extends AuthBlocState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
}