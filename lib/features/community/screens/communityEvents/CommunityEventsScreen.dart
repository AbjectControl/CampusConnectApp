import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:flutter/material.dart';

class CommunityEventsScreen extends StatelessWidget {
  const CommunityEventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: "Community Events", centerTitle: true),
      body: Center(child: Text("Community Events Screen")),
    );
  }
}
