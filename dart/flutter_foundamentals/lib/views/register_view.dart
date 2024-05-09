import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundamentals/services/auth/auth_exception.dart';
import 'package:flutter_foundamentals/dialogs/error_dialog.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_event.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
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
    return BlocListener<AuthBloc, AuthBlocState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordException) {
            await showGenericErrorDialog(context, "Password is too weak.");
          } else if (state.exception is EmailInUseException) {
            await showGenericErrorDialog(context, "Email already in use.");
          } else {
            await showGenericErrorDialog(context, "Error while registering.");
          }
        }
      },
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Register"),
            backgroundColor: Colors.amber,
          ),
          // center vertically/horizontally the widget
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
                onPressed: () async {
                  context.read<AuthBloc>().add(
                        AuthEventRegister(
                          email: _email.text,
                          password: _password.text,
                        ),
                      );
                },
                child: const Text("Register"),
              ),
              TextButton(
                  onPressed: () {
                    // Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);
                    context.read<AuthBloc>().add(const AuthEventLogOut());
                  },
                  child: const Text("Go to Log-in"))
            ],
          )),
    );
  }
}
