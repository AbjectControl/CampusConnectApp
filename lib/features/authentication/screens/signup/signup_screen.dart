import 'package:cconnect/common/widgets/loaders/fullscreen_loader.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/features/authentication/controllers/signup/signup_controller.dart';
import 'package:cconnect/features/authentication/screens/signup/widgets/already_have_account_text.dart';
import 'package:cconnect/features/authentication/screens/signup/widgets/signup_form.dart';
import 'package:cconnect/features/authentication/screens/signup/widgets/signup_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SignUpController(
        authRepo: FirebaseAuthRepository(),
        userRepo: UserRepository.instance,
      ),
      child: Consumer<SignUpController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: Stack(
              children: [
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SignUpHeader(),
                          SignUpForm(),
                          AlreadyHaveAccountText(),
                        ],
                      ),
                    ),
                  ),
                ),
                if (controller.isLoading) const FullScreenLoader(),
              ],
            ),
          );
        },
      ),
    );
  }
}
