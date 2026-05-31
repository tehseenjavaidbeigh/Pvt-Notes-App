import 'package:flutter/material.dart';
import 'package:pvtnotes/services/auth/auth_services.dart';
import 'package:pvtnotes/views/notes/Notes_view.dart';
import 'package:pvtnotes/views/Register_view.dart';
import 'package:pvtnotes/views/login_view.dart';
import 'package:pvtnotes/views/notes/new_note_view.dart';
import 'package:pvtnotes/views/verifyemail_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomePage(),
      routes: {
        "/login/": (context) => const LoginView(),
        "/register/": (context) => const RegisterView(),
        "/notes/": (context) => const MainUi(),
        "/verify-email/": (context) => const VerifyEmail(),
        "/notes/new-note/": (context) => const NewNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const MainUi();
              } else {
                return const VerifyEmail();
              }
            } else {
              return const LoginView();
            }

          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}
