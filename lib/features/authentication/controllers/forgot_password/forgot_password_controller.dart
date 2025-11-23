import 'package:cconnect/data/repositories/interfaces/iauth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordController extends ChangeNotifier {
  final IAuthRepository authRepo;

  ForgotPasswordController({required this.authRepo});

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isLoading = false;

  Future<void> handleReset(BuildContext context, VoidCallback onSuccess) async {
    if (!formKey.currentState!.validate()) return;

    isLoading = true;
    notifyListeners();

    try {
      await authRepo.resetPassword(emailController.text.trim());
      onSuccess(); // Navigate outside the controller
    } catch (_) {
      // Error is shown by ToastService/SnackbarService inside FirebaseAuthRepository
    }

    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
