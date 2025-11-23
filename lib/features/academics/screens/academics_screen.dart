import 'package:flutter/material.dart';

class AcademicsScreen extends StatelessWidget {
  const AcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academics"),
        centerTitle: true,
      ),
      body: const Center(
        child: Text("Academics Screen"),
      ),
    );
  }
}
