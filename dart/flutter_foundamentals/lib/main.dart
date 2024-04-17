import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foundamentals/firebase_options.dart';
import 'package:flutter_foundamentals/views/login_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      useMaterial3: true,
    ),
    home: const HomePage(),
  ));
}

/**
 * Stateless widget to initialize Firebase Auth
 */
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Log-In"),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder(
          future: Firebase.initializeApp(
              options: DefaultFirebaseOptions.currentPlatform),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                final currentUser = FirebaseAuth.instance.currentUser;
                final isUserVerified = currentUser?.emailVerified ?? false;
                if (isUserVerified) {
                  print("verified");
                } else {
                  print("not verified");
                }
                return Text("Done");
              default:
                return const Text('Loading');
            }
          }),
    );
  }
}
