import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final bool loading;
  final VoidCallback onSubmit;
  final void Function(bool) setLoading;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.loading,
    required this.onSubmit,
    required this.setLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          TextFormField(
            controller: emailCtrl,
            decoration: InputDecoration(
              labelText: AppStrings.email,
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: Sizing.allCircular12,
              ),
            ),
            validator: (v) => v!.isEmpty ? AppStrings.enterEmail : null,
          ),
          Sizing.h16,
          TextFormField(
            controller: passCtrl,
            decoration: InputDecoration(
              labelText: AppStrings.password,
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: Sizing.allCircular12,
              ),
            ),
            obscureText: true,
            validator: (v) => v!.isEmpty ? AppStrings.enterPassword : null,
          ),
          Sizing.h24,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: loading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                padding: Sizing.paddingAll16,
                shape: RoundedRectangleBorder(
                  borderRadius: Sizing.allCircular12,
                ),
              ),
              child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AppStrings.login),
            ),
          ),
        ],
      ),
    );
  }
}
