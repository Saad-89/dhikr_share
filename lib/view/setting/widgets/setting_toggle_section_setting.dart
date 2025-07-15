import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

// Custom Toggle Item Widget
class SettingsToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color iconColor;
  final Color iconBackgroundColor;

  const SettingsToggleItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
    this.iconColor = AppColors.primaryDarkGreen,
    this.iconBackgroundColor = const Color(0xFFE8F5E8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon container
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),

          const SizedBox(width: 16),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: title,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.left,
                  color: Colors.black87,
                ),
                const SizedBox(height: 4),
                AppText(
                  text: description,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  textAlign: TextAlign.left,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),

          // Toggle switch
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: AppColors.primaryDarkGreen,
              activeTrackColor: AppColors.primaryDarkGreen.withOpacity(0.5),
              inactiveThumbColor: Colors.grey[400],
              inactiveTrackColor: Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}

// Settings Toggle Section Widget
class SettingsToggleSection extends StatefulWidget {
  final Function(String, bool)? onToggleChanged;

  const SettingsToggleSection({Key? key, this.onToggleChanged})
    : super(key: key);

  @override
  State<SettingsToggleSection> createState() => _SettingsToggleSectionState();
}

class _SettingsToggleSectionState extends State<SettingsToggleSection> {
  bool voiceRecognition = true;
  bool visualFeedback = true;
  bool hapticFeedback = true;

  void _handleToggle(String setting, bool value) {
    setState(() {
      switch (setting) {
        case 'voice':
          voiceRecognition = value;
          break;
        case 'visual':
          visualFeedback = value;
          break;
        case 'haptic':
          hapticFeedback = value;
          break;
      }
    });

    // Callback to parent widget
    widget.onToggleChanged?.call(setting, value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SettingsToggleItem(
            icon: Icons.mic,
            title: "Voice Recognition",
            description: "Enable AI-powered voice detection for dhikr phrases",
            value: voiceRecognition,
            onChanged: (value) => _handleToggle('voice', value),
          ),

          const SizedBox(height: 16),

          SettingsToggleItem(
            icon: Icons.visibility,
            title: "Visual Feedback",
            description: "Show visual animations when phrases are detected",
            value: visualFeedback,
            onChanged: (value) => _handleToggle('visual', value),
          ),

          const SizedBox(height: 16),

          SettingsToggleItem(
            icon: Icons.vibration,
            title: "Haptic Feedback",
            description: "Vibrate when dhikr phrases are detected",
            value: hapticFeedback,
            onChanged: (value) => _handleToggle('haptic', value),
          ),
        ],
      ),
    );
  }
}
