import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _visualFeedbackKey = 'visual_feedback_enabled';
  static const String _hapticFeedbackKey = 'haptic_feedback_enabled';
  static const String _voiceRecognitionEnabledKey = 'voice_recognition_enabled';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _prayerTimesEnabledKey = 'prayer_times_enabled';
  static const String _hanafiCalculationKey = 'hanafi_calculation';

  // Voice feedback settings
  Future<bool> getVisualFeedbackEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_visualFeedbackKey) ?? true;
  }

  Future<void> setVisualFeedbackEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visualFeedbackKey, enabled);
  }

  Future<bool> getHapticFeedbackEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hapticFeedbackKey) ?? true;
  }

  Future<void> setHapticFeedbackEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticFeedbackKey, enabled);
  }

  Future<bool> getVoiceRecognitionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_voiceRecognitionEnabledKey) ?? true;
  }

  Future<void> setVoiceRecognitionEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_voiceRecognitionEnabledKey, enabled);
  }

  Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<String> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'light';
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language);
  }

  Future<bool> getPrayerTimesEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prayerTimesEnabledKey) ?? true;
  }

  Future<void> setPrayerTimesEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prayerTimesEnabledKey, enabled);
  }

  Future<bool> getHanafiCalculation() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hanafiCalculationKey) ?? false;
  }

  Future<void> setHanafiCalculation(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hanafiCalculationKey, enabled);
  }
}
