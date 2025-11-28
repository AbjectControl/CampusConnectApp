import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/routes/routes.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: AppStrings.community,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTile(
            context,
            icon: Icons.poll_rounded,
            title: "Community Surveys",
            subtitle: "Share your opinions and participate in campus polls",
            routeName: AppRoutes.communitySurveys,
          ),
          _buildTile(
            context,
            icon: Icons.event_rounded,
            title: "Community Events",
            subtitle: "Discover and join campus events and activities",
            routeName: AppRoutes.communityEvents,
          ),
          _buildTile(
            context,
            icon: Icons.search_rounded,
            title: "Community Lost & Found",
            subtitle: "Report lost items or help find missing belongings",
            routeName: AppRoutes.communityLostFound,
          ),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String routeName,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFE8F0FE),
          child: Icon(icon, color: Colors.blue, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: () {
          Navigator.pushNamed(context, routeName);
        },
      ),
    );
  }
}
