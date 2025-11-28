import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:flutter/material.dart';

class CommunitySurveysScreen extends StatelessWidget {
  const CommunitySurveysScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: "Community Surveys", centerTitle: true),
      body: Center(child: Text("Community Surveys Screen")),
    );
  }
}
