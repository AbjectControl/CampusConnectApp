import 'dart:async';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/helpers/snack_bar.dart';
import 'package:flutter/material.dart';

class EmailVerifyScreen extends StatefulWidget {
  final String email;
  const EmailVerifyScreen({required this.email, super.key});

  @override
  State<EmailVerifyScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerifyScreen> {
  late Timer _timer;
  bool _isVerified = false;
  final FirebaseAuthRepository _authRepo = FirebaseAuthRepository();

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      final verified = await _authRepo.isEmailVerified();
      if (verified) {
        setState(() {
          _isVerified = true;
        });
        _timer.cancel();
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.authGate,
            (route) => false,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isVerified
            ? const Text('Email verified! Redirecting...')
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Text(
                      'A verification email was sent to ${widget.email}.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                  Sizing.h8,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: const Text(
                      'Please verify your email to continue.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Sizing.h16,
                  Padding(
                    padding: Sizing.paddingAll16,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: Sizing.allCircular16,
                        ),
                      ),
                      onPressed: () async {
                        try {
                          await _authRepo.sendEmailVerification();
                        } catch (e) {
                          // Error handled in repo
                        }
                      },
                      child: const Text('Resend Email'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
