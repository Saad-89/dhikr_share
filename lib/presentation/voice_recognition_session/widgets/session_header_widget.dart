import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionHeaderWidget extends StatelessWidget {
  final int sessionDuration;
  final String selectedPhrase;
  final Function(String) onPhraseChanged;
  final VoidCallback onClose;

  const SessionHeaderWidget({
    super.key,
    required this.sessionDuration,
    required this.selectedPhrase,
    required this.onPhraseChanged,
    required this.onClose,
  });

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final phraseOptions = [
      'All Phrases',
      'SubhanAllah',
      'Alhamdulillah',
      'Allahu Akbar',
      'La ilaha illa Allah',
      'Astaghfirullah',
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: onClose,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
              child: CustomIconWidget(
                iconName: 'close',
                size: 20,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),

          SizedBox(width: 4.w),

          // Session timer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Voice Recognition Session',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'access_time',
                      size: 16,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatDuration(sessionDuration),
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Phrase selection dropdown
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary,
                width: 1,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedPhrase,
                isDense: true,
                icon: CustomIconWidget(
                  iconName: 'keyboard_arrow_down',
                  size: 18,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
                items: phraseOptions.map((String phrase) {
                  return DropdownMenuItem<String>(
                    value: phrase,
                    child: Text(
                      phrase,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onPhraseChanged(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
