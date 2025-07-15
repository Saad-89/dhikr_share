import 'package:flutter/material.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';

class ProgressHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final VoidCallback onClose;

  const ProgressHeader({
    super.key,
    required this.step,
    required this.totalSteps,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final progress = step / totalSteps;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$step/$totalSteps',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.primaryGreen,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.grey),
              onPressed: onClose,
            ),
          ],
        ),
        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            color: AppColors.primaryGreen,
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
