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

    on<AuthEventForgotPassword>((event, emit) async {
      log("auth_bloc::AuthEventForgotPassword:event: $event");
      final email = event.email;
      if (email == null) {
        log("auth_bloc::AuthEventForgotPassword: email is null");
        emit(const AuthStateForgotPassword(hasSentEmail: false));
        // go to reset password view
        return;
      }

      // send email
      log("auth_bloc::AuthEventForgotPassword:emit: loading");
      emit(const AuthStateForgotPassword(
        hasSentEmail: false,
        isLoading: true,
      ));

      bool didEmailSent = true;
      Exception? exception;

      try {
        await provider.resetPassword(email: email);
      } on Exception catch (e) {
        log("auth_bloc::AuthEventForgotPassword:exception $e");
        didEmailSent = false;
        exception = e;
      }
      log("auth_bloc::AuthEventForgotPassword:emit: result");
      emit(AuthStateForgotPassword(
        hasSentEmail: didEmailSent,
        exception: exception,
      ));
    });
  }
}
