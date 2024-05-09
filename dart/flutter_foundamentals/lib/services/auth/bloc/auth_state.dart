import 'package:flutter/foundation.dart';
import 'package:flutter_foundamentals/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthBlocState {
  const AuthBlocState();
}

class AuthStateLoggedIn extends AuthBlocState {
  final AuthUser user;

  const AuthStateLoggedIn(this.user);
}

class AuthStateNeedsVerification extends AuthBlocState {
  const AuthStateNeedsVerification();
}

class AuthStateLoggedOut extends AuthBlocState with EquatableMixin {
  final Exception? exception;
  final bool isLoading;
  const AuthStateLoggedOut({
    this.exception,
    required this.isLoading,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateUninitialized extends AuthBlocState {
  const AuthStateUninitialized();
}

class AuthStateRegistering extends AuthBlocState {
  final Exception? exception;
  const AuthStateRegistering({
    this.exception,
  });
}
