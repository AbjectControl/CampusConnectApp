import 'package:cconnect/data/repositories/interfaces/iauth.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginController {
  final IAuthRepository authRepo;
  final IUserRepository userRepo;

  LoginController({required this.authRepo, required this.userRepo});

  Future<void> login(
    BuildContext context, {
    required String email,
    required String password,
    required VoidCallback onStart,
    required VoidCallback onStop,
    required VoidCallback onSuccess,
    required void Function(String msg) onError,
  }) async {
    onStart();

    try {
      // 1️⃣ Login to Firebase auth
      final user = await authRepo.signInWithEmail(email, password);

      // ignore: unnecessary_null_comparison
      if (user == null) {
        onError("User record not found");
        return;
      }

      // 3️⃣ Store in Provider
      Provider.of<UserProvider>(context, listen: false).setUser(user);

      // 4️⃣ Trigger success handler
      onSuccess();
    } catch (e) {
      onError("Login failed: $e");
    } finally {
      onStop();
    }
  }
}
