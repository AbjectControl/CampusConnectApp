import 'package:cconnect/common/widgets/loaders/fullscreen_loader.dart';
import 'package:cconnect/common/widgets/texts/text_widget.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/features/authentication/controllers/Login/loginController.dart';
import 'package:cconnect/features/authentication/screens/login/widgets/login_form.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool loading = false;

  late final loginCtrl = LoginController(
    authRepo: FirebaseAuthRepository(),
    userRepo: FirebaseUserRepository(),
  );

  void setLoading(bool v) {
    if (mounted) setState(() => loading = v);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final outlineColor = theme.colorScheme.outline;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: Sizing.paddingSymmetricH24,
                child: Column(
                  children: [
                    Sizing.h24,
                    AppText(
                      AppStrings.welcomeBack,
                      style: theme.textTheme.headlineMedium,
                    ),
                    Sizing.h8,
                    AppText(
                      AppStrings.signInWithEmailPassword,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                      useOutlineColor: true,
                    ),
                    Sizing.h24,
                    LoginForm(
                      formKey: formKey,
                      emailCtrl: emailCtrl,
                      passCtrl: passCtrl,
                      loading: loading,
                      setLoading: setLoading,
                      onSubmit: () {
                        if (!formKey.currentState!.validate()) return;

                        loginCtrl.login(
                          context,
                          email: emailCtrl.text.trim(),
                          password: passCtrl.text.trim(),
                          onStart: () => setLoading(true),
                          onStop: () => setLoading(false),
                          onError: (msg) => SnackbarService.error(msg),
                          onSuccess: () {
                            Navigator.pushReplacementNamed(context, "/home");
                          },
                        );
                      },
                    ),
                    Sizing.h32,
                    const AppText(AppStrings.googleLogin, useOutlineColor: true),
                    Sizing.h8,
                    Material(
                      color: theme.colorScheme.surface,
                      shape: RoundedRectangleBorder(
                        borderRadius: Sizing.allCircular16,
                        side: BorderSide(color: primaryColor),
                      ),
                      elevation: 0,
                      child: InkWell(
                        onTap: () {
                          // Google Sign In Logic would go here
                          SnackbarService.info("Google Sign In not implemented yet");
                        },
                        borderRadius: Sizing.allCircular16,
                        child: Padding(
                          padding: Sizing.paddingAll8,
                          child: SvgPicture.string(
                            googleIco,
                            height: 40,
                            width: 40,
                            placeholderBuilder: (context) =>
                                const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                    Sizing.h24,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppStrings.noAccount,
                          style: TextStyle(color: outlineColor),
                        ),
                        GestureDetector(
                          onTap: () {
                             // Navigate to sign up
                             SnackbarService.info("Sign Up not implemented yet");
                          },
                          child: Text(
                            AppStrings.signUp,
                            style: TextStyle(color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                    Sizing.h24,
                  ],
                ),
              ),
            ),
          ),
          if (loading) const FullScreenLoader(),
        ],
      ),
    );
  }
}
