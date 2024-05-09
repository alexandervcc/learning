import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/dialogs/loading_dialog.dart';
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
  CloseDialog? _closeDialogHandle;

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
    log("login_view::build::context: $context");
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) async {
        log("login_view::BlocListener::state $state");
        if (state is AuthStateLoggedOut) {
          log("login_view::BlocListener::state.exception: ${state.exception}");
          final closeDialog = _closeDialogHandle;

          if (!state.isLoading && closeDialog != null) {
            closeDialog();
            _closeDialogHandle = null;
          } else if (state.isLoading && closeDialog == null) {
            _closeDialogHandle = showLoadingDialog(
              context: context,
              text: "Loading...",
            );
          }

          if (state.exception != null) {
            if (state.exception is UserNotFoundException) {
              await showGenericErrorDialog(context, "User not found.");
            } else if (state.exception is InvalidEmailException) {
              await showGenericErrorDialog(context, "Email is malformed.");
            } else {
              await showGenericErrorDialog(context, "Invalid credentials.");
            }
          }
        }
      },
      child: Scaffold(
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
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(AuthEventLogIn(
                        email: _email.text,
                        password: _password.text,
                      ));
                },
                child: const Text("Log In"),
              ),
              TextButton(
                  onPressed: () {
                    // Navigator: with named route
                    // Navigator.of(context).pushNamedAndRemoveUntil(signupRoute, (route) => false);
                    context
                        .read<AuthBloc>()
                        .add(const AuthEventShoulRegister());
                  },
                  child: const Text("Sign-Up here"))
            ],
          )),
    );
  }
}
