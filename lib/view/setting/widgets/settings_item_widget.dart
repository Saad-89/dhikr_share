import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SettingsItemWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFE8F5E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  leadingIcon,
                  color: textColor ?? AppColors.primaryDarkGreen,
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
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? AppColors.black,
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    AppText(
                      text: subtitle!,
                      textAlign: TextAlign.start,

                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                      color: AppColors.black54,
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Icon(
                        Icons.arrow_forward,
                        color: AppColors.black54,
                        size: 20,
                      )
                    : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}
