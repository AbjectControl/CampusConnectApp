import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Sizing.h24,
        Text(
          AppStrings.createAccount,
          style: theme.textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        Sizing.h8,
        Text(
          AppStrings.signUpWithEmailPassword,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        Sizing.h24,
      ],
    );
  }
}
