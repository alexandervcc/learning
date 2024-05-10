import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter_foundamentals/services/auth/auth_provider.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_event.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthBlocEvent, AuthBlocState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateUninitialized()) {
    on<AuthEventSendEmailVerification>((event, emit) async {
      await provider.sendEmailVerification();
      emit(state);
    });

    on<AuthEventRegister>((event, emit) async {
      try {
        final email = event.email;
        final password = event.password;
        await provider.createUser(email: email, password: password);
        await provider.sendEmailVerification();
        emit(const AuthStateNeedsVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(
          exception: e,
        ));
      }
    });

    on<AuthEventInitialize>((event, emit) async {
      await provider.initializeApp();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
        return;
      }
      if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
        return;
      }
      emit(AuthStateLoggedIn(
        user: user,
      ));
    });

    on<AuthEventShoulRegister>((event, emit) {
      emit(const AuthStateRegistering());
    });

    on<AuthEventLogIn>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(
          isLoading: true,
          loadingText: "Wait while you are being logged in",
        ));

        final email = event.email;
        final password = event.password;

        final authUser = await provider.logIn(email: email, password: password);

        emit(const AuthStateLoggedOut());

        if (!authUser.isEmailVerified) {
          emit(const AuthStateNeedsVerification());
          return;
        }

        emit(AuthStateLoggedIn(
          user: authUser,
        ));
      } on Exception catch (e) {
        log("auth_bloc::AuthEventLogIn::e: $e");
        emit(AuthStateLoggedOut(
          exception: e,
        ));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthStateLoggedOut(isLoading: true));
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLoggedOut(exception: e));
      }
    });
  }
}
