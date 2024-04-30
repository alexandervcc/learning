import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/services/auth/auth_exception.dart';
import 'package:flutter_foundamentals/services/auth/auth_service.dart';
import 'package:flutter_foundamentals/dialogs/error_dialog.dart';

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
    return Scaffold(
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
                final email = _email.text;
                final password = _password.text;
                try {
                  await AuthService.firebase().createUser(
                    email: email,
                    password: password,
                  );
                  await AuthService.firebase().sendEmailVerification();
                  Navigator.of(context).pushNamed(verifyEmailRoute);
                } on WeakPasswordException catch (_) {
                  await showGenericErrorDialog(
                      context, "Weak password, use a new one");
                } on EmailInUseException catch (_) {
                  await showGenericErrorDialog(
                      context, "Email you provided cannot be used");
                } on GenericAuthException catch (e) {
                  await showGenericErrorDialog(context, "Error: $e");
                }
              },
              child: const Text("Register"),
            ),
            TextButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(loginRoute, (route) => false);
                },
                child: const Text("Go to Log-in"))
          ],
        ));
  }
}
