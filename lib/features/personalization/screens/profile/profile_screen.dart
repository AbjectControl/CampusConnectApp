import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Profile Screen"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuthRepository().signOut();
                // AuthGate will handle the redirection
              },
              child: const Text("Sign Out"),
            ),
          ],
        ),
      ),
    );
  }
}
