import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/onBoarding/welcome_screen/welcome_Screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dhikar App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryGreen),
      ),
      home: WelcomeScreen(),
    );
  }
}
