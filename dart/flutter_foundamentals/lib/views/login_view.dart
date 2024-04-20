import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/utils/show_error_dialog.dart';

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
            TextButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final user = FirebaseAuth.instance.currentUser;
                  log("LoggedIn user: $user");
                  if (!(user?.emailVerified ?? false)) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        verifyEmailRoute, (route) => false);
                    return;
                  }
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil(homeRoute, (route) => false);
                } on FirebaseAuthException catch (e) {
                  log("Error authenticating user: $e");
                  if (e.code == "invalid-email") {
                    await showErrorDialog(context, "Invalid email");
                  } else if (e.code == "invalid-credential") {
                    await showErrorDialog(context, "Invalid credentials");
                  } else {
                    await showErrorDialog(context, "Error: ${e.code}");
                  }
                }
              },
              child: const Text("Log In"),
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
