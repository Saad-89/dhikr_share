import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/setting/widgets/general_setting_widget.dart';
import 'package:dhikar_share/view/setting/widgets/hanafi_calculation_toggle_widget.dart';
import 'package:dhikar_share/view/setting/widgets/prayer_times_widget.dart';
import 'package:dhikar_share/view/setting/widgets/setting_section_widget.dart';
import 'package:dhikar_share/view/setting/widgets/setting_toggle_section_setting.dart';
import 'package:dhikar_share/view/setting/widgets/settings_item_widget.dart';
import 'package:dhikar_share/view/setting/widgets/settings_selection_widget.dart';
import 'package:dhikar_share/view/setting/widgets/settings_toggle_widget.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  void _onToggleChanged(String setting, bool value) {
    // Handle toggle changes here
    print('$setting changed to: $value');

    // You can save to SharedPreferences, call APIs, etc.
    switch (setting) {
      case 'voice':
        // Enable/disable voice recognition
        break;
      case 'visual':
        // Enable/disable visual feedback
        break;
      case 'haptic':
        // Enable/disable haptic feedback
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.menuBackGroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.menuBackGroundColor,
        centerTitle: true,
        title: Text('Settings', style: TextStyle(color: AppColors.black)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            // Voice Recognition & Feedback Settings
            // SettingsSectionWidget(
            //   title: 'Voice Recognition & Feedback',
            //   children: [
            //     SettingsToggleWidget(
            //       leadingIcon: 'mic',
            //       title: 'Voice Recognition',
            //       subtitle:
            //           'Enable AI-powered voice detection for dhikr phrases',
            //       value: true,
            //       onChanged: (_) {},
            //     ),
            //     SettingsToggleWidget(
            //       leadingIcon: 'visibility',
            //       title: 'Visual Feedback',
            //       subtitle: 'Show visual animations when phrases are detected',
            //       value: true,
            //       onChanged: (_) {},
            //     ),
            //     SettingsToggleWidget(
            //       leadingIcon: 'vibration',
            //       title: 'Haptic Feedback',
            //       subtitle: 'Vibrate when dhikr phrases are detected',
            //       value: true,
            //       onChanged: (_) {},
            //     ),
            //   ],
            // ),

            // Settings Toggle Section
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                AppText(
                  text: 'Voice Recognition & Feedback',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black,
                ),
              ],
            ),
            SizedBox(height: 3),

            SettingsToggleSection(onToggleChanged: _onToggleChanged),
            SizedBox(height: 3),

            // General Settings
            SettingsWidget(),

            // SettingsSectionWidget(
            //   title: 'General',
            //   children: [
            //     SettingsToggleWidget(
            //       leadingIcon: 'notifications',
            //       title: 'Notifications',
            //       subtitle: 'Enable prayer time and dhikr reminders',
            //       value: true,
            //       onChanged: (_) {},
            //     ),
            //     SettingsSelectionWidget(
            //       leadingIcon: 'palette',
            //       title: 'Theme',
            //       subtitle: 'Choose your preferred app theme',
            //       options: ['light', 'dark', 'system'],
            //       selectedValue: 'light',
            //       onChanged: (_) {},
            //     ),
            //     SettingsSelectionWidget(
            //       leadingIcon: 'language',
            //       title: 'Language',
            //       subtitle: 'Select your preferred language',
            //       selectedValue: 'en',
            //       options: ['en', 'ar', 'ur'],
            //       onChanged: (_) {},
            //     ),
            //   ],
            // ),
            SizedBox(height: 3),

            // Prayer Times Settings
            SettingsSectionWidget(
              title: 'Prayer Times',
              children: [
                SettingsToggleWidget(
                  leadingIcon: 'access_time',
                  title: 'Prayer Times',
                  subtitle: 'Show prayer times in the app',
                  value: true,
                  onChanged: (_) {},
                ),
                HanafiCalculationToggleWidget(),
                PrayerTimesWidget(),
              ],
            ),

            SizedBox(height: 3),

            // Account Settings
            SettingsSectionWidget(
              title: 'Account',
              children: [
                SettingsItemWidget(
                  leadingIcon: 'backup',
                  title: 'Backup Data',
                  subtitle: 'Backup your dhikr progress to cloud',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Backup feature coming soon'),
                      ),
                    );
                  },
                ),
                SettingsItemWidget(
                  leadingIcon: 'download',
                  title: 'Export Data',
                  subtitle: 'Export your data to external storage',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Export feature coming soon'),
                      ),
                    );
                  },
                ),
                SettingsItemWidget(
                  leadingIcon: 'logout',
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: () {
                    // Show confirmation dialog if needed
                  },
                ),
              ],
            ),

            SizedBox(height: 3),

            // About Section
            SettingsSectionWidget(
              title: 'About',
              children: [
                SettingsItemWidget(
                  leadingIcon: 'privacy_tip',
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {},
                ),
                SettingsItemWidget(
                  leadingIcon: 'description',
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  onTap: () {},
                ),
                SettingsItemWidget(
                  leadingIcon: 'info',
                  title: 'App Version',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
              ],
            ),

            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class SettingScreen extends StatelessWidget {
//   const SettingScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           "Setting Screen",
//           style: TextStyle(color: Colors.black, fontSize: 20),
//         ),
//       ),
//     );
//   }
// }
