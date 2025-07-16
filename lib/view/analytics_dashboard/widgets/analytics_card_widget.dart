import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AnalyticsCardWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final String? subtitle;
  final VoidCallback? onTap;

  const AnalyticsCardWidget({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          // border: Border.all(color: AppColors.grey, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: 10),
                        Text(
                          subtitle!,
                          // style:
                          //     AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          //   color: AppTheme.lightTheme.colorScheme.onSurface
                          //       .withValues(alpha: 0.7),
                          // ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.chevron_right,
                    // color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    //   alpha: 0.5,
                    // ),
                    size: 20,
                  ),
              ],
            ),
            SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}
