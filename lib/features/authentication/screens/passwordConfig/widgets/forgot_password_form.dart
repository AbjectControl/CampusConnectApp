import 'package:cconnect/common/widgets/forms/custom_textformfield.dart';
import 'package:cconnect/features/authentication/controllers/forgot_password/forgot_password_controller.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordForm extends StatelessWidget {
  const ForgotPasswordForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ForgotPasswordController>(context);
    final theme = Theme.of(context);

    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: controller.emailController,
            labelText: AppStrings.emailLabel,
            hintText: AppStrings.enterEmail,
            svgIcon: mailIcon,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.requiredField;
              }
              return null;
            },
          ),
          Sizing.h64,
          ElevatedButton(
            onPressed: controller.isLoading
                ? null
                : () {
                    controller.handleReset(
                      context,
                      () => Navigator.pop(context),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: controller.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(AppStrings.continueBtn),
          ),
        ],
      ),
    );
  }
}
