import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class DailyGoalCircle extends StatelessWidget {
  final int current;
  final int total;

  const DailyGoalCircle({Key? key, required this.current, required this.total})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFF52C4A0), width: 3),
      ),
      child: Center(
        child: AppText(
          text: '$current/$total',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF52C4A0),
        ),
      ),
    );
  }
}
