import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: AppStrings.academics, centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Academics Screen'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.mentorshipRequest);
              },
              icon: const Icon(Icons.school),
              label: const Text('Request Mentorship'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
