import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/firebase_options.dart';
import 'package:flutter_foundamentals/views/login_view.dart';
import 'package:flutter_foundamentals/views/notes_view.dart';
import 'package:flutter_foundamentals/views/register_view.dart';
import 'package:flutter_foundamentals/views/verify_email.dart';
// import only log from the package and use an alias
import 'dart:developer' as devtools show log;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
    // create named routes
    routes: {
      "/log-in/": (context) => const LoginView(),
      "/sign-up/": (context) => const RegisterView()
    },
  ));
}

/// Stateless widget to initialize Firebase Auth
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser == null) {
                devtools.log('No user yet, showing Log-In view');
                return const LoginView();
              }

              final isUserVerified = currentUser.emailVerified;
              if (!isUserVerified) {
                devtools.log(
                    'User still needs verification, showing Email Verification view');
                return const VerifyEmailView();
              }
              // main application page
              devtools.log('User set, accessing to main app');
              return const NotesView();
            default:
              return const CircularProgressIndicator();
          }
        });
  }
}
