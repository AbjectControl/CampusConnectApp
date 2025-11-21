import 'package:cconnect/common/widgets/loaders/fullscreen_loader.dart';
import 'package:cconnect/common/widgets/navigation/main_nav_screen.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/user.dart';
import 'package:cconnect/features/authentication/screens/onboarding/onboarding_screen.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return StreamBuilder<fb.User?>(
      stream: FirebaseAuthRepository().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const FullScreenLoader();
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;

          return FutureBuilder<User?>(
            future: FirebaseUserRepository().fetchUser(user.uid),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return Scaffold(
                  body: Center(
                    child: LoadingAnimationWidget.stretchedDots(
                      color: theme.colorScheme.primary,
                      size: 60,
                    ),
                  ),
                );
              }

              if (userSnapshot.hasData) {
                final appUser = userSnapshot.data!;
                
                // Use addPostFrameCallback to avoid setState during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                   Provider.of<UserProvider>(
                    context,
                    listen: false,
                  ).setUser(appUser);
                });

                // Check for incomplete profile if needed
                // For now, go straight to MainNavScreen
                return const MainNavScreen();
              }

              // If user is authenticated in Firebase but not in Firestore (edge case)
              // You might want to redirect to a profile creation screen or sign out
              return const MainNavScreen(); // Fallback
            },
          );
        }

        return const OnboardingScreen();
      },
    );
  }
}
