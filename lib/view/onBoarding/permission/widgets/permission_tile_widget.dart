import 'package:flutter/material.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';

class PermissionTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const PermissionTile({
    super.key,
    required this.icon,
    required this.text,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: AppColors.white, size: 20),
          ),
          // Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: AppColors.black),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: onChanged,
            inactiveTrackColor: AppColors.white,
            inactiveThumbColor: AppColors.primaryGreen,
            activeColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }
}
