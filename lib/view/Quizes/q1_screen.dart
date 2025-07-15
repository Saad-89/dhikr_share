import 'package:flutter/material.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:dhikar_share/view/Quizes/widgets/progress_header.dart';
import 'package:dhikar_share/view/Quizes/widgets/question_option_tile.dart';
import 'package:dhikar_share/view/Quizes/q2_screen.dart'; // 👈 Make sure this path is correct

class SpiritualFocusQuestionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final String selectionType; // 'single' or 'multiple'

  const SpiritualFocusQuestionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selectionType,
  });

  @override
  State<SpiritualFocusQuestionScreen> createState() =>
      _SpiritualFocusQuestionScreenState();
}

class _SpiritualFocusQuestionScreenState
    extends State<SpiritualFocusQuestionScreen> {
  List<String> selectedOptions = [];

  final List<Map<String, String>> options = [
    {"emoji": "🕛", "label": "Fajr (before)"},
    {"emoji": "🌞", "label": "Mid-"},
    {"emoji": "🕒", "label": "Midday"},
    {"emoji": "🏙️", "label": "Evening"},
    {"emoji": "🌙", "label": "Late night"},
    {"emoji": "❓", "label": "It varies"},
  ];

  void handleTap(String label) {
    setState(() {
      if (widget.selectionType == 'single') {
        selectedOptions = [label];
      } else {
        if (selectedOptions.contains(label)) {
          selectedOptions.remove(label);
        } else {
          selectedOptions.add(label);
        }
      }
    });
  }

  void handleNext() {
    if (selectedOptions.isNotEmpty) {
      print("Selected: $selectedOptions");

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const DailyDkhikrTimeQuestionScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select at least one option.")),
      );
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
                step: 1,
                totalSteps: 4,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              AppText(
                text: widget.title,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 8),
              AppText(
                text: widget.subtitle,
                fontSize: 14,
                fontWeight: FontWeight.normal,
                color: AppColors.black54,
              ),
              const SizedBox(height: 24),

              ...options.map(
                (opt) => QuestionOptionTile(
                  emoji: opt['emoji']!,
                  label: opt['label']!,
                  selected: selectedOptions.contains(opt['label']),
                  onTap: () => handleTap(opt['label']!),
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
