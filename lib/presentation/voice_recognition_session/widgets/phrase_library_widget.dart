import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhraseLibraryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dhikrPhrases;
  final VoidCallback onClose;

  const PhraseLibraryWidget({
    super.key,
    required this.dhikrPhrases,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          width: 90.w,
          height: 70.h,
          margin: EdgeInsets.symmetric(horizontal: 5.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Dhikr Phrase Library',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: onClose,
                      child: Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: 'close',
                          size: 20,
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Phrase list
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.all(4.w),
                  itemCount: dhikrPhrases.length,
                  separatorBuilder: (context, index) => SizedBox(height: 2.h),
                  itemBuilder: (context, index) {
                    final phrase = dhikrPhrases[index];
                    return _buildPhraseCard(phrase);
                  },
                ),
              ),

              // Footer with tips
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppTheme.lightTheme.colorScheme.outline.withValues(
                        alpha: 0.3,
                      ),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'info_outline',
                      size: 16,
                      color: AppTheme.lightTheme.colorScheme.primary,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Speak clearly and at a moderate pace for best recognition',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhraseCard(Map<String, dynamic> phrase) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Arabic text
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.05,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              phrase['arabic'] ?? '',
              style: AppTheme.arabicTextStyle(isLight: true).copyWith(
                fontSize: 18.sp,
                color: AppTheme.lightTheme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
            ),
          ),

          SizedBox(height: 2.h),

          // Transliteration
          Row(
            children: [
              CustomIconWidget(
                iconName: 'record_voice_over',
                size: 16,
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  phrase['transliteration'] ?? '',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 1.h),

          // Meaning
          Row(
            children: [
              CustomIconWidget(
                iconName: 'translate',
                size: 16,
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  phrase['meaning'] ?? '',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Recognition tips
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'tips_and_updates',
                  size: 14,
                  color: AppTheme.lightTheme.colorScheme.secondary,
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    'Try pronouncing: "${phrase['transliteration']}"',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
