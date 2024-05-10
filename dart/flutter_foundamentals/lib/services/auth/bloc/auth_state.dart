import 'package:flutter/foundation.dart';
import 'package:flutter_foundamentals/services/auth/auth_user.dart';
import 'package:equatable/equatable.dart';

@immutable
abstract class AuthBlocState {
  final bool isLoading;
  final String? loadingText;

  const AuthBlocState({
    this.isLoading = false,
    this.loadingText = "Please wait a moment.",
  });
}

class AuthStateLoggedIn extends AuthBlocState {
  final AuthUser user;

  const AuthStateLoggedIn({required this.user, super.isLoading});
}

class AuthStateNeedsVerification extends AuthBlocState {
  const AuthStateNeedsVerification({super.isLoading});
}

class AuthStateLoggedOut extends AuthBlocState with EquatableMixin {
  final Exception? exception;

  const AuthStateLoggedOut({
    this.exception,
    super.isLoading,
    super.loadingText,
  });

  @override
  List<Object?> get props => [exception, isLoading];
}

class AuthStateUninitialized extends AuthBlocState {
  const AuthStateUninitialized({
    super.isLoading,
  });
}

class AuthStateRegistering extends AuthBlocState {
  final Exception? exception;
  const AuthStateRegistering({
    this.exception,
    super.isLoading,
  });
}
