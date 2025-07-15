import 'package:dhikar_share/view/Quizes/dhikr_plan_ready_screen.dart/goal_plan_ready_screen.dart';
import 'package:flutter/material.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/Quizes/widgets/progress_header.dart';
import 'package:dhikar_share/view/Quizes/widgets/question_option_tile.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/app_text.dart';

class DhikrPreferanceQuestionScreen extends StatefulWidget {
  const DhikrPreferanceQuestionScreen({super.key});

  @override
  State<DhikrPreferanceQuestionScreen> createState() =>
      _DhikrPreferanceQuestionScreenState();
}

class _DhikrPreferanceQuestionScreenState
    extends State<DhikrPreferanceQuestionScreen> {
  List<String> selectedOptions = [];

  final List<Map<String, String>> options = [
    {"emoji": "🎤", "label": "Voice (speaking aloud)"},
    {"emoji": "📿", "label": "Manual tap"},
    {"emoji": "🧘", "label": "Quiet/internal"},
    {"emoji": "🧭", "label": "Guided prompts/counts"},
    {"emoji": "❓", "label": "No preference"},
  ];

  void toggleOption(String label) {
    setState(() {
      if (selectedOptions.contains(label)) {
        selectedOptions.remove(label);
      } else {
        selectedOptions.add(label);
      }
    });
  }

  void handleNext() {
    if (selectedOptions.isNotEmpty) {
      print("Selected options: $selectedOptions");

      // Example next step navigation (currently commented out)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DhikrPlanReadyScreen()),
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
                step: 4,
                totalSteps: 4,
                onClose: () => Navigator.pop(context),
              ),
              const SizedBox(height: 24),
              const Center(
                child: AppText(
                  text: "How do you prefer to do\n dhikr?",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: AppText(
                  text: "(Select all that apply)",
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.black54,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              ...options.map(
                (opt) => QuestionOptionTile(
                  emoji: opt['emoji']!,
                  label: opt['label']!,
                  selected: selectedOptions.contains(opt['label']),
                  onTap: () => toggleOption(opt['label']!),
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
