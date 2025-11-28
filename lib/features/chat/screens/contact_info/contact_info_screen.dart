import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/data/models/userModel.dart';
import 'package:cconnect/utils/constraints/sizing.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class ContactInfoScreen extends StatelessWidget {
  final User user;

  const ContactInfoScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Extract metadata safely
    final department = user.department ?? AppStrings.notProvided;
    final semester = user.section ?? AppStrings.notProvided;

    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.contactInfo,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: Sizing.paddingAll16,
        child: Column(
          children: [
            Sizing.h24,
            // Avatar
            CircleAvatar(
              radius: 60,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null ? const Icon(Icons.person, size: 60) : null,
            ),
            Sizing.h16,
            // Name
            Text(
              user.displayName,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            // Department (Subtitle)
            Text(
              department,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            Sizing.h32,
            
            // Info Card
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
                children: [
                  _buildInfoRow(context, Icons.school, AppStrings.department, department),
                  const Divider(height: 32),
                  _buildInfoRow(context, Icons.layers, AppStrings.semester, semester),
                ],
              ),
            ),
            Sizing.h32,
            
            // Actions
            _buildActionTile(
              context, 
              AppStrings.sendMessage, 
              Icons.message, 
              () => Navigator.pop(context), // Go back to chat
            ),
            const Divider(),
            _buildActionTile(
              context, 
              AppStrings.reportUser, 
              Icons.report_problem, 
              () {
                // Placeholder for report logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Report submitted")),
                );
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.blue),
        ),
        Sizing.w16,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              Text(value, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
