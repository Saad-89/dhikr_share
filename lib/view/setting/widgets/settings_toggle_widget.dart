import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SettingsToggleWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String leadingIcon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.leadingIcon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.leaderboard,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black, // or any color you want for title
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 0.5),
                  AppText(
                    text: subtitle!,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColors.black54,
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryGreen, // Using your custom app color
            activeTrackColor: AppColors.primaryGreen.withOpacity(0.5),
            inactiveThumbColor: Colors.grey[300],
            inactiveTrackColor: Colors.grey[400],
          ),
        ],
      ),
    );
  }
}
