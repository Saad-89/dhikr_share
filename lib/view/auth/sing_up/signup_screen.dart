import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/auth/sign_in/sign_in.dart';
import 'package:dhikar_share/view/onBoarding/Dhkir_goal/set_goal_screen.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:dhikar_share/widgets/svg_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppText(
                text: 'Create Your Account',
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              const AppText(
                text:
                    'Start your dhikr journey with saved goals, reminders, and\ncommunity features.',
                fontSize: 14,
                color: AppColors.black54,
              ),
              const SizedBox(height: 32),

              IntlPhoneField(
                decoration: InputDecoration(
                  hintText: '000 - 000 - 000',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                initialCountryCode: 'US',
                onChanged: (phone) {
                  print(phone.completeNumber);
                },
              ),

              const SizedBox(height: 16),
              AppButton(
                width: MediaQuery.of(context).size.width,
                height: 50,
                text: 'Sign Up',
                onPressed: () {
                  // Navigate or show setup logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SetGoalScreen()),
                  );
                },
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: SafeSvgWidget(
                        assetPath: 'assets/svgs/google_icon.svg',
                        width: 20,
                        height: 20,
                      ),
                      // Image.asset(
                      //   'assets/images/google_icon.png',
                      //   height: 20,
                      // ),
                      label: const Text(
                        'Google',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: SafeSvgWidget(
                        assetPath: 'assets/svgs/apple_icon.svg',
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                      // Image.asset(
                      //   'assets/images/apple_icon.png',
                      //   height: 20,
                      //   color: Colors.white,
                      // ),
                      label: const Text(
                        'Apple',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              RichText(
                text: TextSpan(
                  text: 'Already have an account? ',
                  style: const TextStyle(color: AppColors.black54),
                  children: [
                    TextSpan(
                      text: 'Log in here.',
                      style: const TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SigninScreen(),
                            ),
                          );
                        },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
