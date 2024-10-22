import 'package:flutter/material.dart';

import '../../auth/facebook.dart';
import '../ui.dart';

class AuthSandboxPage extends StatelessWidget {
  const AuthSandboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () {
            FacebookAuthService.getUserData();
          },
          child: const Text("Facebook Auth"),
        ),
        TextButton(
          onPressed: () async {
            await showOtpDialog(
              context,
              email: "test@test.com",
              mobile: "0771448678",
            );
          },
          child: const Text("Show Otp Page"),
        ),
        TextButton(
          onPressed: () async {
            await showIdentityDialog(context);
          },
          child: const Text("Show Test Page"),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(30),
        //   child: const FacebookSignOnButton(),
        // ),
        // const SizedBox(height: 10),
        // Padding(
        //   padding: const EdgeInsets.all(30),
        //   child: const GoogleSignOnButton(),
        // )
      ],
    );
  }
}
