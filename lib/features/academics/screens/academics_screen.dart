import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:cconnect/features/academics/screens/mentorship_request_screen.dart';
import 'package:flutter/material.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academics'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Academics Screen'),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MentorshipRequestScreen()),
                );
              },
              icon: const Icon(Icons.school),
              label: const Text('Request Mentorship'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
