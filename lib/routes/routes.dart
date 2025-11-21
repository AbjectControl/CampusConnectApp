import 'package:cconnect/common/widgets/navigation/main_nav_screen.dart';
import 'package:cconnect/features/authentication/screens/login/screens/Login.dart';
import 'package:cconnect/features/authentication/screens/onboarding/onboarding_screen.dart';
import 'package:cconnect/features/authentication/screens/signup/tempSignup.dart';
import 'package:cconnect/main.dart';
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

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        // Assuming HomeScreen requires a user, but for routing purposes we might need to handle this differently
        // or rely on MainNavScreen to show Home.
        // For now, let's route to MainNavScreen as 'home'
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
      default:
        return MaterialPageRoute(builder: (_) => const AuthGate());
    }
  }
}
