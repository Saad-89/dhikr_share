import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String leadingIcon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  const SettingsItemWidget({
    super.key,
    required this.title,
    this.subtitle,
    required this.leadingIcon,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: leadingIcon,
                  color: textColor ?? AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: textColor ??
                          AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle != null
                      ? Column(
                          children: [
                            SizedBox(height: 0.5.h),
                            Text(
                              subtitle!,
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                      color: AppTheme.textSecondaryLight),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            trailing != null
                ? trailing!
                : onTap != null
                    ? CustomIconWidget(
                        iconName: 'chevron_right',
                        color: AppTheme.textSecondaryLight,
                        size: 20,
                      )
                    : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}
