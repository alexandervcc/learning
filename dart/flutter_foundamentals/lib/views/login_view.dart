import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/services/auth/auth_exception.dart';
import 'package:flutter_foundamentals/services/auth/auth_service.dart';
import 'package:flutter_foundamentals/dialogs/error_dialog.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_event.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_state.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  //Proxy to obtain a single store for text across children components
  late final TextEditingController _email;
  late final TextEditingController _password;
  // late: same as lateinit on kotlin

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Log-In"),
          backgroundColor: Colors.amber,
        ),
        body: Column(
          children: [
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(hintText: "email"),
            ),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: "password",
              ),
            ),
            BlocListener<AuthBloc, AuthBlocState>(
              listener: (context, state) async {
                log("login_view::BlocListener::state $state");
                if (state is AuthStateLoggedOut) {
                  log("login_view::BlocListener::state.exception: ${state.exception}");
                  if (state.exception is UserNotFoundException) {
                    await showGenericErrorDialog(context, "User not found.");
                  } else if (state.exception is InvalidEmailException) {
                    await showGenericErrorDialog(
                        context, "Email is malformed.");
                  } else {
                    await showGenericErrorDialog(
                        context, "Invalid credentials.");
                  }
                }
              },
              child: TextButton(
                onPressed: () => blocHandleLogIn(
                  context: context,
                  email: _email.text,
                  password: _password.text,
                ),
                child: const Text("Log In"),
              ),
            ),
            TextButton(
                onPressed: () {
                  // Navigator: with named route
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(signupRoute, (route) => false);
                },
                child: const Text("Sign-Up here"))
          ],
        ));
  }
}

Future<void> blocHandleLogIn({
  required BuildContext context,
  required String email,
  required String password,
}) async =>
    context
        .read<AuthBloc>()
        .add(AuthEventLogIn(email: email, password: password));

/// Old error dialog
@Deprecated('Use [blocHandleLogIn]')
Future<void> handleLogIn({
  required BuildContext context,
  required String email,
  required String password,
}) async {
  try {
    await AuthService.firebase().logIn(
      email: email,
      password: password,
    );
    final user = AuthService.firebase().currentUser;
    log("LoggedIn user: $user");
    if (!(user?.isEmailVerified ?? false)) {
      Navigator.of(context)
          .pushNamedAndRemoveUntil(verifyEmailRoute, (route) => false);
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(homeRoute, (route) => false);
  } on InvalidEmailException catch (_) {
    await showGenericErrorDialog(context, "Invalid email");
  } on GenericAuthException catch (_) {
    await showGenericErrorDialog(context, "Invalid credentials");
  }
}
