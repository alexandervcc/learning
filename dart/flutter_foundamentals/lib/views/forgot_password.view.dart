import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundamentals/dialogs/error_dialog.dart';
import 'package:flutter_foundamentals/dialogs/send_reset_email.dialog.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_event.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_state.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _emailController;

  @override
  void initState() {
    _emailController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) async {
        log("forgor_password_view::build::BlocListener::listener:state: ${state.toString()}");
        if (state is AuthStateForgotPassword) {
          if (state.exception != null) {
            log("forgor_password_view::build::BlocListener::listener:e: ${state.exception}");
            await showGenericErrorDialog(
              context,
              "Request was not able to be processed",
            );
            return;
          }
          if (state.hasSentEmail && state.exception == null) {
            _emailController.clear();
            await showResetPasswordDialog(context: context);
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Reset password"),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "If forgot password, enter your email and we will send you a reset link.",
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  autofocus: true,
                  decoration:
                      const InputDecoration(hintText: "Enter your email"),
                  controller: _emailController,
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(
                          AuthEventForgotPassword(
                            email: _emailController.text,
                          ),
                        );
                  },
                  child: const Text("Send email"),
                ),
                TextButton(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text("Back to Log-In page"),
                )
              ],
            ),
          )),
    );
  }
}
