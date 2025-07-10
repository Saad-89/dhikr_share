import 'package:dhikr_share/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_service.dart';
import '../../services/prayer_time_service.dart';
import '../../services/settings_service.dart';
import './widgets/hanafi_calculation_toggle_widget.dart';
import './widgets/prayer_times_widget.dart';
import './widgets/settings_item_widget.dart';
import './widgets/settings_section_widget.dart';
import './widgets/settings_selection_widget.dart';
import './widgets/settings_toggle_widget.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  final SettingsService _settingsService = SettingsService();
  // final AuthService _authService = AuthService();
  final LocationService _locationService = LocationService();
  final PrayerTimeService _prayerTimeService = PrayerTimeService();

  bool _notificationsEnabled = true;
  bool _visualFeedbackEnabled = true;
  bool _hapticFeedbackEnabled = true;
  bool _voiceRecognitionEnabled = true;
  bool _prayerTimesEnabled = true;
  bool _hanafiCalculation = false;
  String _selectedTheme = 'light';
  String _selectedLanguage = 'en';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await Future.wait([
        _settingsService.getNotificationsEnabled(),
        _settingsService.getVisualFeedbackEnabled(),
        _settingsService.getHapticFeedbackEnabled(),
        _settingsService.getVoiceRecognitionEnabled(),
        _settingsService.getPrayerTimesEnabled(),
        _settingsService.getHanafiCalculation(),
        _settingsService.getTheme(),
        _settingsService.getLanguage(),
      ]);

      if (mounted) {
        setState(() {
          _notificationsEnabled = settings[0] as bool;
          _visualFeedbackEnabled = settings[1] as bool;
          _hapticFeedbackEnabled = settings[2] as bool;
          _voiceRecognitionEnabled = settings[3] as bool;
          _prayerTimesEnabled = settings[4] as bool;
          _hanafiCalculation = settings[5] as bool;
          _selectedTheme = settings[6] as String;
          _selectedLanguage = settings[7] as String;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateVisualFeedback(bool value) async {
    await _settingsService.setVisualFeedbackEnabled(value);
    setState(() {
      _visualFeedbackEnabled = value;
    });
  }

  Future<void> _updateHapticFeedback(bool value) async {
    await _settingsService.setHapticFeedbackEnabled(value);
    setState(() {
      _hapticFeedbackEnabled = value;
    });
  }

  Future<void> _updateVoiceRecognition(bool value) async {
    await _settingsService.setVoiceRecognitionEnabled(value);
    setState(() {
      _voiceRecognitionEnabled = value;
    });
  }

  Future<void> _updateNotifications(bool value) async {
    await _settingsService.setNotificationsEnabled(value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  Future<void> _updatePrayerTimes(bool value) async {
    await _settingsService.setPrayerTimesEnabled(value);
    setState(() {
      _prayerTimesEnabled = value;
    });
  }

  Future<void> _updateHanafiCalculation(bool value) async {
    await _settingsService.setHanafiCalculation(value);
    setState(() {
      _hanafiCalculation = value;
    });
  }

  Future<void> _updateTheme(String theme) async {
    await _settingsService.setTheme(theme);
    setState(() {
      _selectedTheme = theme;
    });
  }

  Future<void> _updateLanguage(String language) async {
    await _settingsService.setLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Confirm Logout'),
            content: Text(
              'Are you sure you want to logout? Your local data will be preserved.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              Consumer<AuthViewmodel>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ElevatedButton(
                    onPressed: () {
                      provider.signOut(context);
                      // Navigator.pop(context);
                      // // await _authService.signOut();
                      // if (mounted) {
                      //   Navigator.pushNamedAndRemoveUntil(
                      //     context,
                      //     '/login-screen',
                      //     (route) => false,
                      //   );
                      // }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    ),
                    child: Text(
                      'Logout',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Settings')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // Voice Recognition & Feedback Settings
            SettingsSectionWidget(
              title: 'Voice Recognition & Feedback',
              children: [
                SettingsToggleWidget(
                  leadingIcon: 'mic',
                  title: 'Voice Recognition',
                  subtitle:
                      'Enable AI-powered voice detection for dhikr phrases',
                  value: _voiceRecognitionEnabled,
                  onChanged: _updateVoiceRecognition,
                ),
                SettingsToggleWidget(
                  leadingIcon: 'visibility',
                  title: 'Visual Feedback',
                  subtitle: 'Show visual animations when phrases are detected',
                  value: _visualFeedbackEnabled,
                  onChanged: _updateVisualFeedback,
                ),
                SettingsToggleWidget(
                  leadingIcon: 'vibration',
                  title: 'Haptic Feedback',
                  subtitle: 'Vibrate when dhikr phrases are detected',
                  value: _hapticFeedbackEnabled,
                  onChanged: _updateHapticFeedback,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // General Settings
            SettingsSectionWidget(
              title: 'General',
              children: [
                SettingsToggleWidget(
                  leadingIcon: 'notifications',
                  title: 'Notifications',
                  subtitle: 'Enable prayer time and dhikr reminders',
                  value: _notificationsEnabled,
                  onChanged: _updateNotifications,
                ),
                SettingsSelectionWidget(
                  leadingIcon: 'palette',
                  title: 'Theme',
                  subtitle: 'Choose your preferred app theme',
                  options: ['light', 'dark', 'system'],
                  selectedValue: _selectedTheme,
                  onChanged: _updateTheme,
                ),
                SettingsSelectionWidget(
                  leadingIcon: 'language',
                  title: 'Language',
                  subtitle: 'Select your preferred language',
                  selectedValue: _selectedLanguage,
                  options: ['en', 'ar', 'ur'],
                  onChanged: _updateLanguage,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // Prayer Times Settings
            SettingsSectionWidget(
              title: 'Prayer Times',
              children: [
                SettingsToggleWidget(
                  leadingIcon: 'access_time',
                  title: 'Prayer Times',
                  subtitle: 'Show prayer times in the app',
                  value: _prayerTimesEnabled,
                  onChanged: _updatePrayerTimes,
                ),
                if (_prayerTimesEnabled)
                  HanafiCalculationToggleWidget(
                    onChanged: _updateHanafiCalculation,
                  ),
                if (_prayerTimesEnabled) PrayerTimesWidget(),
              ],
            ),

            SizedBox(height: 3.h),

            // Account Settings
            SettingsSectionWidget(
              title: 'Account',
              children: [
                SettingsItemWidget(
                  leadingIcon: 'backup',
                  title: 'Backup Data',
                  subtitle: 'Backup your dhikr progress to cloud',
                  onTap: () {
                    // TODO: Implement backup functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Backup feature coming soon')),
                    );
                  },
                ),
                SettingsItemWidget(
                  leadingIcon: 'download',
                  title: 'Export Data',
                  subtitle: 'Export your data to external storage',
                  onTap: () {
                    // TODO: Implement export functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Export feature coming soon')),
                    );
                  },
                ),
                SettingsItemWidget(
                  leadingIcon: 'logout',
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  onTap: _showLogoutConfirmation,
                ),
              ],
            ),

            SizedBox(height: 3.h),

            // About Section
            SettingsSectionWidget(
              title: 'About',
              children: [
                SettingsItemWidget(
                  leadingIcon: 'privacy_tip',
                  title: 'Privacy Policy',
                  subtitle: 'Read our privacy policy',
                  onTap: () {
                    // TODO: Navigate to privacy policy
                  },
                ),
                SettingsItemWidget(
                  leadingIcon: 'description',
                  title: 'Terms of Service',
                  subtitle: 'Read our terms of service',
                  onTap: () {
                    // TODO: Navigate to terms of service
                  },
                ),
                SettingsItemWidget(
                  leadingIcon: 'info',
                  title: 'App Version',
                  subtitle: '1.0.0',
                  onTap: null,
                ),
              ],
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}
