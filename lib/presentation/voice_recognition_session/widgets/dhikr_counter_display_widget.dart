import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DhikrCounterDisplayWidget extends StatelessWidget {
  final Map<String, int> dhikrCounts;
  final int totalCount;
  final String lastDetectedPhrase;
  final AnimationController counterController;

  const DhikrCounterDisplayWidget({
    super.key,
    required this.dhikrCounts,
    required this.totalCount,
    required this.lastDetectedPhrase,
    required this.counterController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total count display
          AnimatedBuilder(
            animation: counterController,
            builder: (context, child) {
              final scale = 1.0 + (counterController.value * 0.1);
              return Transform.scale(
                scale: scale,
                child: Column(
                  children: [
                    Text(
                      'Total Dhikr',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      totalCount.toString(),
                      style: AppTheme.dhikrCounterStyle(isLight: true).copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontSize: 36.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: 3.h),

          // Individual phrase counts
          _buildPhraseCountsGrid(),

          if (lastDetectedPhrase.isNotEmpty) ...[
            SizedBox(height: 2.h),
            _buildLastDetectedPhrase(),
          ],
        ],
      ),
    );
  }

  Widget _buildPhraseCountsGrid() {
    final phrases = dhikrCounts.entries.toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 2.w,
        mainAxisSpacing: 1.h,
      ),
      itemCount: phrases.length,
      itemBuilder: (context, index) {
        final entry = phrases[index];
        final isLastDetected = entry.key == lastDetectedPhrase;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isLastDetected
                ? AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  )
                : AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isLastDetected
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.outline.withValues(
                      alpha: 0.3,
                    ),
              width: isLastDetected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                entry.key,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: isLastDetected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                entry.value.toString(),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: isLastDetected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLastDetectedPhrase() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'volume_up',
              size: 16,
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),

          SizedBox(width: 3.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last Detected',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  lastDetectedPhrase,
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Pulse animation indicator
          AnimatedBuilder(
            animation: counterController,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 1.0 - counterController.value,
                  ),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
