import 'package:cconnect/common/widgets/forms/custom_textformfield.dart';
import 'package:cconnect/features/authentication/controllers/signup/signup_controller.dart';
import 'package:cconnect/utils/constraints/appicons.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<SignUpController>(context);
    final theme = Theme.of(context);

    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            labelText: AppStrings.emailLabel,
            hintText: AppStrings.enterEmail,
            svgIcon: mailIcon,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterEmail;
              }
              return null;
            },
          ),
          Padding(
            padding: Sizing.paddingSymmetricV8,
            child: CustomTextFormField(
              controller: controller.passwordController,
              obscureText: true,
              labelText: AppStrings.passwordLabel,
              hintText: AppStrings.enterPassword,
              svgIcon: lockIcon,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseEnterPassword;
                }
                if (value.length < 6) {
                  return AppStrings.passwordTooShort;
                }
                return null;
              },
            ),
          ),
          Padding(
            padding: Sizing.paddingSymmetricV8,
            child: CustomTextFormField(
              controller: controller.repeatPasswordController,
              obscureText: true,
              labelText: AppStrings.reenterPasswordLabel,
              hintText: AppStrings.enterPassword,
              svgIcon: lockIcon,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return AppStrings.pleaseReenterPassword;
                }
                if (value != controller.passwordController.text) {
                  return AppStrings.passwordsDoNotMatch;
                }
                return null;
              },
            ),
          ),
          Sizing.h24,
          ElevatedButton(
            onPressed: controller.isLoading
                ? null
                : () => controller.signUp(context),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 48),
              shape: const RoundedRectangleBorder(
                borderRadius: Sizing.allCircular16,
              ),
            ),
            child: controller.isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(AppStrings.continueBtn),
          ),
          Sizing.h32,
        ],
      ),
    );
  }
}
