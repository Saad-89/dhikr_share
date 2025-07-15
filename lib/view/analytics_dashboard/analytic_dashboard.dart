import 'package:flutter/material.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Analytics Dashboard",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }
}
