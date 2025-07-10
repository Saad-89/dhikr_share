import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EmptyFriendsStateWidget extends StatelessWidget {
  final VoidCallback onInviteFriends;

  const EmptyFriendsStateWidget({super.key, required this.onInviteFriends});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'people_outline',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 64,
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Title
            Text(
              'Build Your Spiritual Community',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.h),
            // Description
            Text(
              'Invite friends to join your spiritual journey.\nShare progress, send encouragement, and\ngrow together in faith.',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            // Benefits
            _buildBenefitItem('Share daily Dhikr progress', 'trending_up'),
            SizedBox(height: 2.h),
            _buildBenefitItem('Send Islamic encouragement', 'favorite'),
            SizedBox(height: 2.h),
            _buildBenefitItem('Join spiritual challenges', 'emoji_events'),
            SizedBox(height: 6.h),
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onInviteFriends,
                icon: CustomIconWidget(
                  iconName: 'person_add',
                  color: AppTheme
                      .lightTheme.floatingActionButtonTheme.foregroundColor!,
                  size: 20,
                ),
                label: const Text('Invite Friends'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Share app functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Share link copied to clipboard!'),
                    ),
                  );
                },
                icon: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                label: const Text('Share Dhikr Share App'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
              ),
            ),
            SizedBox(height: 4.h),
            // Islamic quote
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'format_quote',
                    color: AppTheme.lightTheme.colorScheme.tertiary,
                    size: 24,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '"The believers in their mutual kindness, compassion, and sympathy are just one body; if a limb suffers, the whole body responds to it with wakefulness and fever."',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    '- Prophet Muhammad (ﷺ)',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text, String iconName) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.tertiary.withValues(
              alpha: 0.1,
            ),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 16,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(text, style: AppTheme.lightTheme.textTheme.bodyMedium),
        ),
      ],
    );
  }
}
