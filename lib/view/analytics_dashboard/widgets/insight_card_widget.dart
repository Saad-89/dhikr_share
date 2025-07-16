import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class InsightCardWidget extends StatelessWidget {
  final String insight;

  const InsightCardWidget({super.key, required this.insight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.lightGrey2,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(
        //   color: AppColors.primaryDarkGreen.withValues(alpha: 0.2),
        //   width: 1,
        // ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryDarkGreen.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.lightbulb,
              color: AppColors.primaryDarkGreen,
              size: 20,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Insight',
                  // style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  //   color: AppColors.primaryGreen,
                  //   fontWeight: FontWeight.w600,
                  // ),
                ),
                SizedBox(height: 10),
                Text(
                  insight,
                  // style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  //   height: 1.4,
                  // ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
