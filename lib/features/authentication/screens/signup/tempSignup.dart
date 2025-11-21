import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/data/repositories/functions/ManagerFunctions/fun.dart';
import 'package:cconnect/main.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool loading = false;

  late final auth = AuthManager(
    authRepo: FirebaseAuthRepository(),
    userRepo: FirebaseUserRepository(),
  );

  signUpUser() async {
    setState(() => loading = true);

    try {
      final user = await auth.signUp(
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(user: user)),
      );
    } catch (e) {
      SnackbarService.error(e.toString());
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: loading ? null : signUpUser,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
