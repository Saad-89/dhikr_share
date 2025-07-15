import 'package:dhikar_share/view/Quizes/q3_screen.dart';
import 'package:dhikar_share/view/Quizes/widgets/progress_header.dart';
import 'package:dhikar_share/view/Quizes/widgets/question_option_tile.dart';
import 'package:flutter/material.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';

class DailyDkhikrTimeQuestionScreen extends StatefulWidget {
  const DailyDkhikrTimeQuestionScreen({super.key});

  @override
  State<DailyDkhikrTimeQuestionScreen> createState() =>
      _DailyDkhikrTimeQuestionScreenState();
}

class _DailyDkhikrTimeQuestionScreenState
    extends State<DailyDkhikrTimeQuestionScreen> {
  String? selectedOption;

  final List<Map<String, String>> options = [
    {"emoji": "", "label": "3–5 minutes"},
    {"emoji": "", "label": "5–10 minutes"},
    {"emoji": "", "label": "10–15 minutes"},
    {"emoji": "", "label": "15+ minutes"},
    {"emoji": "", "label": "Let the app decide"},
  ];

  void selectOption(String label) {
    setState(() {
      selectedOption = label;
    });
  }

  void handleNext() {
    if (selectedOption != null) {
      print("Selected option: $selectedOption");
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UsuallyFreetimeForDhikrQuestionScreen(),
        ),
      );
    } else {
      print("No option selected.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProgressHeader(
                step: 2,
                totalSteps: 4,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              Center(
                child: const AppText(
                  text: "How much time can you\ngive to dhikr daily?",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: const AppText(
                  text: "(Choose one)",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.black54,
                ),
              ),
              const SizedBox(height: 24),

              ...options.map(
                (opt) => QuestionOptionTile(
                  emoji: opt['emoji']!,
                  label: opt['label']!,
                  selected: selectedOption == opt['label'],
                  onTap: () => selectOption(opt['label']!),
                ),
              ),

              const SizedBox(height: 32),
              AppButton(
                text: 'Next',
                width: double.infinity,
                height: 50,
                onPressed: handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
