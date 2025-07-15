import 'package:flutter/material.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Dkhir Counter",
          style: TextStyle(color: Colors.black, fontSize: 20),
        ),
      ),
    );
  }
}
