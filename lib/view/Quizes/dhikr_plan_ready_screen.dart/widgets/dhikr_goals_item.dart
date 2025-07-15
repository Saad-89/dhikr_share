// Custom widget for dhikr goal item
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class DhikrGoalItem extends StatelessWidget {
  final IconData leftIcon;
  final IconData rightIcon;
  final String count;
  final String description;
  final Color iconColor;

  const DhikrGoalItem({
    Key? key,
    required this.leftIcon,
    required this.rightIcon,
    required this.count,
    required this.description,
    this.iconColor = const Color(0xFF52C4A0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left icon
          Icon(leftIcon, color: iconColor, size: 24),

          // Center text
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppText(
                text: '$count $description',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
                color: Colors.black87,
              ),
            ),
          ),

          // Right icon
          Icon(rightIcon, color: iconColor, size: 24),
        ],
      ),
    );
  }
}
