import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SettingsSelectionWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leadingIcon;
  final List<String> options;
  final String selectedValue;
  final ValueChanged<String> onChanged;

  const SettingsSelectionWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingIcon,
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showSelectionDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.grey,
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryGreen, // used primary color here
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: subtitle,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColors.black54,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.primaryGreen, size: 20),
          ],
        ),
      ),
    );
  }

  void _showSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        title: AppText(
          text: 'Select $title',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryGreen, // used primary color here
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == selectedValue;

              return ListTile(
                title: AppText(
                  text: option,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppColors.primaryGreen
                      : AppColors.primaryGreen.withOpacity(
                          0.7,
                        ), // subtle variation
                ),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primaryGreen, size: 20)
                    : null,
                onTap: () {
                  onChanged(option);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: AppText(
              text: 'Cancel',
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: AppColors.primaryGreen,
            ),
          ),
        ],
      ),
    );
  }
}
