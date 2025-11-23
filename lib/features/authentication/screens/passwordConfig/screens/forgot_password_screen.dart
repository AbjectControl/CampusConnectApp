import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:cconnect/features/authentication/controllers/forgot_password/forgot_password_controller.dart';
import 'package:cconnect/features/authentication/screens/passwordConfig/widgets/forgot_password_form.dart';
import 'package:cconnect/features/authentication/screens/passwordConfig/widgets/forgot_password_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ForgotPasswordController(
        authRepo: FirebaseAuthRepository(),
      ),
      child: const Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ForgotPasswordHeader(),
                ForgotPasswordForm(),
                SizedBox(height: 48),
                // Reusing AlreadyHaveAccountText but we might want a "No Account? Sign Up" text instead
                // The user provided "NoAccountText" which links to SignUp.
                // I'll reuse AlreadyHaveAccountText logic but adapt if needed or create NoAccountText if strictly required.
                // The user provided code for NoAccountText which is basically "Don't have an account? Sign Up".
                // Let's use a new widget for that to match the request exactly.
                NoAccountText(), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NoAccountText extends StatelessWidget {
  const NoAccountText({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.outline;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account? ", style: TextStyle(color: color)),
        GestureDetector(
          onTap: () {
            // Assuming AppRoutes.signUp is defined and imported via routes.dart (not imported here yet, need to fix imports if this was separate file)
            // Since this is inside the same file for now or I should make it separate?
            // The user asked for "no account text (already implemented in login)" but the code provided was a separate class.
            // I will implement it here for simplicity or import it if I created it.
            // Wait, I didn't create NoAccountText yet. I'll create it as a separate widget to be clean.
             Navigator.pushReplacementNamed(context, '/signUp');
          },
          child: Text(
            "Sign Up",
            style: TextStyle(color: theme.colorScheme.primary),
          ),
        ),
      ],
    );
  }
}
