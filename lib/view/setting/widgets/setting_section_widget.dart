import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: AppText(
            text: title,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.black,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final index = entry.key;
              final child = entry.value;

              return Column(
                children: [
                  child,
                  if (index < children.length - 1)
                    const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 64, // replaced 16.w
                      color: AppColors.black54,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
