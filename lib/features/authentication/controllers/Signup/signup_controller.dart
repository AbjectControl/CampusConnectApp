import 'dart:convert';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/interfaces/iauth.dart';
import 'package:cconnect/data/repositories/interfaces/iuser.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/routes/auth_gate.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/constraints/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class SignUpController extends ChangeNotifier {
  final IAuthRepository authRepo;
  final IUserRepository userRepo;

  SignUpController({required this.authRepo, required this.userRepo});

  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool isLoading = false;

  Future<void> signUp(BuildContext context) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      // Use injected authRepo
      final user = await authRepo.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // Save user to Firestore using injected userRepo
      await userRepo.create(user);

      // Trigger webhook
      try {
        final uri = Uri.parse(WebhookUrls.userSignedUp);
        await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'email': user.email,
            'uid': user.id, // Use user.id instead of user.uid
            'name': user.displayName,
          }),
        );
      } catch (e) {
        debugPrint('Webhook failed: $e');
      }

      // Handle email verification flow
      // Note: FirebaseAuthRepository.signUpWithEmail already sends verification email
      // We just need to navigate to verification screen
      
      if (context.mounted) {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.verifyMailScreen, // Ensure this route is defined
          arguments: user.email,
        );
      }
      
    } catch (e) {
      debugPrint("Signup failed: $e");
      // Error handling is done in repository (showing snackbars)
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }
}
