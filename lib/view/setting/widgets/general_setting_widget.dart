import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

// USAGE EXAMPLES:

// 1. In a full screen page:
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            SettingsWidget(),
            // You can add more settings sections here
          ],
        ),
      ),
    );
  }
}

// 2. In a dialog:
void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => Dialog(child: const SettingsWidget()),
  );
}

// 3. In a bottom sheet:
void showSettingsBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => const SettingsWidget(),
  );
}

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSettingsItem(
            icon: Icons.notifications_outlined,
            iconColor: AppColors.primaryDarkGreen,
            title: 'Notifications',
            subtitle: 'Enable prayer time and dhikr reminders',
            trailing: Switch(
              value: notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                });
              },
              activeColor: AppColors.primaryDarkGreen,
            ),
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.palette_outlined,
            iconColor: AppColors.primaryDarkGreen,
            title: 'Theme',
            subtitle: 'Choose your preferred app theme',
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // Handle theme selection
              print('Theme tapped');
            },
          ),
          const SizedBox(height: 16),
          _buildSettingsItem(
            icon: Icons.language_outlined,
            iconColor: AppColors.primaryDarkGreen,
            title: 'Language',
            subtitle: 'Select your preferred language',
            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
            onTap: () {
              // Handle language selection
              print('Language tapped');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: title,

                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    text: subtitle,

                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
