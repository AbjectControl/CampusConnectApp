import 'package:cconnect/common/widgets/texts/text_widget.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class ForgotPasswordHeader extends StatelessWidget {
  const ForgotPasswordHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Sizing.h32,
        AppText(
          AppStrings.forgotPassword,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Sizing.h8,
        const AppText(
          AppStrings.enterEmail, // Reusing existing string or create new one if needed
          textAlign: TextAlign.center,
          useOutlineColor: true,
        ),
        Sizing.h64,
      ],
    );
  }
}
