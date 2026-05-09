import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;
import 'package:pvtnotes/constants/routes.dart';
import 'package:pvtnotes/services/auth/auth_services.dart';
import 'package:pvtnotes/services/auth/auth_exceptions.dart';
import 'package:pvtnotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            enableSuggestions: false,
            autocorrect: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: "Please Enter Your Email",
            ),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(hintText: "Please Enter Your Password"),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase().register(
                  email: email,
                  password: password,
                );

                final user = AuthService.firebase().currentUser;
                await AuthService.firebase().sendEmailVerification();
                Navigator.of(context).pushNamed(verifyEmailRoute);
                devtools.log(user.toString());
              } on EmailAlreadyInUseAuthException {
                await showErrorDialog(context, "Email is already in use");
              } on WeakPasswordAuthException {
                await showErrorDialog(context, "Password is too weak");
              } on InvalidEmailAuthException {
                await showErrorDialog(context, "Invalid Email");
              } on GenericAuthException {
                await showErrorDialog(context, "Authentication Error");
              }
            },
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("Already Registered? Login Here!"),
          ),
        ],
      ),
    );
  }
}
