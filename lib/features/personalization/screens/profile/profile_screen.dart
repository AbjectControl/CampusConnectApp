import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/repositories/functions/FireBaseFunctions/authentication.dart';
import 'package:cconnect/features/chat/controllers/chat_provider.dart';
import 'package:cconnect/features/personalization/controllers/userProvider.dart';
import 'package:cconnect/features/personalization/screens/admin/admin_dashboard_screen.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/constraints/enums.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.myProfile,
        centerTitle: true,
        actions: [
          if (user.role == UserRole.admin || user.role == UserRole.manager)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: AppStrings.adminDashboard,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: Sizing.paddingAll16,
        child: Column(
          children: [
            Sizing.h24,
            // Profile Image
            CircleAvatar(
              radius: 60,
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? const Icon(Icons.person, size: 60)
                  : null,
            ),
            Sizing.h16,
            // Name
            Text(
              user.displayName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Sizing.h8,
            // Student ID
            if (user.studentId != null)
              Text(
                "${AppStrings.studentId}: ${user.studentId}",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
              ),
            Sizing.h32,
            
            // Personal Details Section
            Container(
              padding: Sizing.paddingAll16,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.personalDetails,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Sizing.h16,
                  _buildDetailRow(
                    context,
                    icon: Icons.email_outlined,
                    label: AppStrings.emailAddress,
                    value: user.email,
                  ),
                  const Divider(height: 32),
                  _buildDetailRow(
                    context,
                    icon: Icons.phone_outlined,
                    label: AppStrings.phoneNumber,
                    value: user.phone ?? AppStrings.notProvided,
                  ),
                ],
              ),
            ),
            
            Sizing.h32,
            
            // Edit Profile Button
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.completeProfile,
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: const Color(0xFF0D47A1), // Dark blue
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                AppStrings.editProfile,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            
            Sizing.h24,
            
            // Log Out Button
            TextButton.icon(
              onPressed: () async {
                await FirebaseAuthRepository().signOut();
                if (context.mounted) {
                  Provider.of<UserProvider>(context, listen: false).clearUser();
                  Provider.of<ChatProvider>(context, listen: false).clear();
                }
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text(
                AppStrings.logOut,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Sizing.h24,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF0D47A1)),
        ),
        Sizing.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
