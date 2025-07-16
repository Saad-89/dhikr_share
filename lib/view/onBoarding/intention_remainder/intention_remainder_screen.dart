import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/Quizes/q1_screen.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/svg_widget.dart';
import 'package:flutter/material.dart';
import 'package:dhikar_share/widgets/app_text.dart';

class IntentionReminderScreen extends StatelessWidget {
  const IntentionReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  text: 'A final reminder...',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.grey,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const AppText(
                  text: 'Check your intention.',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const AppText(
                  text:
                      'Your dhikr is for the sake of Allah alone —\nnot for likes, numbers, or recognition.',
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Icon and Reminder Block
                Container(
                  // padding: const EdgeInsets.all(8),
                  // decoration: BoxDecoration(
                  //   color: const Color(0xFFF7F7F7),
                  //   borderRadius: BorderRadius.circular(12),
                  // ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.info, color: Colors.grey, size: 28),
                      SizedBox(width: 8),
                      Expanded(
                        child: AppText(
                          text:
                              'This app is a tool to motivate you and inspire your friends. Not a single Dhikr should be for the sake of competition. Sincerity is the goal. Inspiration is the result.\n\nIf that isn’t you, please come back when you are ready.',
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Image
                SafeSvgWidget(
                  assetPath: 'assets/svgs/tasbhi.svg',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 30),

                AppButton(
                  text: "I'm ready",
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 50,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpiritualFocusQuestionScreen(
                          title: 'When do you feel most spiritually focused?',
                          subtitle: '(Select all that apply)',
                          selectionType: 'multiple',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
