import 'dart:async';
import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/onBoarding/permission/allow_access_screen.dart';
import 'package:flutter/material.dart';
import 'package:dhikar_share/widgets/app_text.dart'; // If using custom text

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotCount;

  @override
  void initState() {
    super.initState();

    // Navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AllowAccessScreen()),
      );
    });

    // Dot animation
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat();

    _dotCount = StepTween(
      begin: 1,
      end: 3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.linear));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildAnimatedDots() {
    return AnimatedBuilder(
      animation: _dotCount,
      builder: (context, child) {
        String dots = '.' * _dotCount.value;
        return Text(
          dots,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            letterSpacing: 5,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            AppText(
              text: 'You will hit it, in shā’ Allāh',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            AppText(
              text: 'إن شاء الله',
              fontSize: 16,
              fontWeight: FontWeight.w200,
              color: AppColors.grey,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            AppText(
              text: 'Stay consistent. Every dhikr counts.',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              color: AppColors.grey,
            ),
            SizedBox(height: 40),
            _AnimatedDots(), // custom widget below
          ],
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatefulWidget {
  const _AnimatedDots({super.key});

  @override
  State<_AnimatedDots> createState() => _AnimatedDotsState();
}

class _AnimatedDotsState extends State<_AnimatedDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _currentDot = 1;

  @override
  void initState() {
    super.initState();

    _controller =
        AnimationController(
          duration: const Duration(milliseconds: 1200),
          vsync: this,
        )..addListener(() {
          final value = (_controller.value * 3).floor() + 1;
          if (value != _currentDot && mounted) {
            setState(() {
              _currentDot = value > 3 ? 1 : value;
            });
          }
        });

    _animation = CurvedAnimation(parent: _controller, curve: Curves.linear);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '.' * _currentDot,
      style: const TextStyle(
        fontSize: 62,
        fontWeight: FontWeight.bold,
        letterSpacing: 6,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
