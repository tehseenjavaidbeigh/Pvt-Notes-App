import 'package:flutter/material.dart';
import 'package:pvtnotes/constants/routes.dart';
import 'package:pvtnotes/services/auth/auth_services.dart';

class VerifyEmail extends StatefulWidget {
  const VerifyEmail({super.key});

  @override
  State<VerifyEmail> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const Text(
            "A verification email has been sent to your email address. Please verify your email to continue.",
          ),
          const Text(
            "If you haven't received a verification email, click the button below to resend.",
          ),
          TextButton(
            onPressed: () async {
              final user = AuthService.firebase().currentUser;
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text("SEND EMAIL VERIFICATION"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text("Login with another account"),
          ),
        ],
      ),
    );
  }
}
