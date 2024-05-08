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

class AuthStateNeedsVerification extends AuthBlocState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthBlocState {
  final Exception? exception;
  const AuthStateLoggedOut(this.exception);
}

class AuthStateLogoutFailure extends AuthBlocState {
  final Exception exception;
  const AuthStateLogoutFailure(this.exception);
}
