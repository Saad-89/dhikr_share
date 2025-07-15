import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/auth/sing_up/signup_screen.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:dhikar_share/widgets/svg_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackGroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image.asset('assets/icons/welcome.png', height: 120),
                SafeSvgWidget(
                  assetPath: 'assets/svgs/tasbhi.svg',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 32),

                const AppText(
                  text: 'As-salāmu ʿalaykum',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                const SizedBox(height: 8),

                const AppText(
                  text: 'Make dhikr contagious.',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
                const SizedBox(height: 24),

                AppButton(
                  text: 'Set Up',
                  onPressed: () {
                    // Navigate or show setup logic
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SignupScreen()),
                    );
                  },
                ),
                const SizedBox(height: 32),

                const AppText(
                  text:
                      'Dhikr Share helps you remember Allah together\nwith your friends — not for numbers or showing off\n(Riya).',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
