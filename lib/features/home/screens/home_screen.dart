import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(title: AppStrings.home, centerTitle: true),
      body: Center(child: Text("Home Screen")),
    );
  }
}
