import 'package:cconnect/common/widgets/navigation/main_nav_screen.dart';
import 'package:cconnect/features/authentication/screens/login/screens/Login.dart';
import 'package:cconnect/features/authentication/screens/onboarding/onboarding_screen.dart';
import 'package:cconnect/features/authentication/screens/passwordConfig/screens/forgot_password_screen.dart';
import 'package:cconnect/features/authentication/screens/signup/screens/email_verify_screen.dart';
import 'package:cconnect/features/authentication/screens/signup/signup_screen.dart';
import 'package:cconnect/features/personalization/screens/complete_profile/complete_profile_screen.dart';
import 'package:cconnect/routes/auth_gate.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  AppRoutes._();

  static const String home = '/home';
  static const String login = '/login';
  static const String signUp = '/signUp';
  static const String onboarding = '/onboarding';
  static const String authGate = '/auth-gate';
  static const String mainNav = '/main-nav';
  static const String verifyMailScreen = '/verify-mail';
  static const String forgotPassword = '/forgot-password';
  static const String completeProfile = '/complete-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const MainNavScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case authGate:
        return MaterialPageRoute(builder: (_) => const AuthGate());
      case mainNav:
        return MaterialPageRoute(builder: (_) => const MainNavScreen());
      case verifyMailScreen:
        final email = settings.arguments as String? ?? '';
        return MaterialPageRoute(builder: (_) => EmailVerifyScreen(email: email));
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
      case completeProfile:
        return MaterialPageRoute(builder: (_) => const CompleteProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
