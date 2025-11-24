import 'package:cconnect/common/widgets/appbar/custom_appbar.dart';
import 'package:cconnect/utils/constraints/strings.dart';
import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppBar(
        title: AppStrings.community,
        centerTitle: true,
      ),
      body: Center(
        child: Text("Community Screen"),
      ),
    );
  }
}
