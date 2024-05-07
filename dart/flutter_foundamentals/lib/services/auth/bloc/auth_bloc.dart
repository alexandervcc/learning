import 'package:bloc/bloc.dart';
import 'package:flutter_foundamentals/services/auth/auth_provider.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_event.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthBlocEvent, AuthBlocState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
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
      emit(AuthStateLoggedIn(user));
    });

    on<AuthEventLogIn>((event, emit) async {
      emit(const AuthStateLoading());

      final email = event.email;
      final password = event.password;

      try {
        final authUser = await provider.logIn(email: email, password: password);
        emit(AuthStateLoggedIn(authUser));
      } on Exception catch (e) {
        emit(AuthStateLoginFailure(e));
      }
    });

    on<AuthEventLogOut>((event, emit) async {
      try {
        emit(const AuthStateLoading());
        await provider.logOut();
        emit(const AuthStateLoggedOut());
      } on Exception catch (e) {
        emit(AuthStateLogoutFailure(e));
      }
    });
  }
}
