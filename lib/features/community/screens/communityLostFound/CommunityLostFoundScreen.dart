import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:flutter/material.dart';

class CommunityLostFoundScreen extends StatelessWidget {
  const CommunityLostFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: "Lost & Found", centerTitle: true),
      body: Center(child: Text("Community Lost & Found Screen")),
    );
  }
}
