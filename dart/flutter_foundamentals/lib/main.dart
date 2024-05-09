import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foundamentals/constants/routes.dart';
import 'package:flutter_foundamentals/services/auth/auth_service.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_bloc.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_event.dart';
import 'package:flutter_foundamentals/services/auth/bloc/auth_state.dart';
import 'package:flutter_foundamentals/views/counter_view.dart';
import 'package:flutter_foundamentals/views/login_view.dart';
import 'package:flutter_foundamentals/views/cu_note_view.dart';
import 'package:flutter_foundamentals/views/notes_view.dart';
import 'package:flutter_foundamentals/views/register_view.dart';
import 'package:flutter_foundamentals/views/verify_email_view.dart';
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
    // BlocProvider will make the bloc available to the widgets inside the tree
    home: BlocProvider<AuthBloc>(
      create: (context) => AuthBloc(AuthService.firebase()),
      child: const HomePage(),
    ),
    // create named routes
    routes: {
      /*
      loginRoute: (context) => const LoginView(),
      signupRoute: (context) => const RegisterView(),
      homeRoute: (context) => const NotesView(),
      verifyEmailRoute: (context) => const VerifyEmailView(),
      */
      cuNoteRoute: (context) => const CUNoteView(),
      counterBlocRoute: (context) => const BlocCounterView()
    },
  ));
}

/// Stateless widget to initialize Firebase Auth
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocBuilder<AuthBloc, AuthBlocState>(builder: (context, state) {
      if (state is AuthStateNeedsVerification) {
        devtools.log(
            'HomePage::BlocBuilder::builder: User still needs verification, showing Email Verification view');
        return const VerifyEmailView();
      }

      if (state is AuthStateLoggedOut) {
        devtools.log(
            'HomePage::BlocBuilder::builder: No user yet, showing Log-In view');
        return const LoginView();
      }

      if (state is AuthStateLoggedIn) {
        devtools.log(
            "HomePage::BlocBuilder::builder: User logged into the application");
        return const NotesView();
      }

      if (state is AuthStateRegistering) {
        devtools.log("HomePage::BlocBuilder::builder: Register new user");
        return const RegisterView();
      }

      devtools.log("HomePage::BlocBuilder::builder: default CircularProgress");
      return const Scaffold(
        body: CircularProgressIndicator(),
      );
    });
  }
}

/// Old error dialog
@Deprecated('Use [HomePage]')
class HomePageWithoutBloc extends StatelessWidget {
  const HomePageWithoutBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: AuthService.firebase().initializeApp(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              final currentUser = AuthService.firebase().currentUser;
              if (currentUser == null) {
                devtools.log('No user yet, showing Log-In view');
                return const LoginView();
              }

              if (!currentUser.isEmailVerified) {
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
