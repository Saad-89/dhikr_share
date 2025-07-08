import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:adhan/adhan.dart';

class PrayerTimeService {
  static const String _apiBaseUrl = 'https://api.aladhan.com/v1';

  // Get prayer times using the Adhan package for accuracy
  static Future<Map<String, DateTime>> calculatePrayerTimes(
    double latitude,
    double longitude,
    DateTime date, {
    bool useHanafiCalculation = false,
  }) async {
    try {
      // First try to get from API for maximum accuracy
      final apiTimes = await _getPrayerTimesFromAPI(
        latitude,
        longitude,
        date,
        useHanafiCalculation: useHanafiCalculation,
      );
      if (apiTimes != null) {
        await _cachePrayerTimes(apiTimes, date);
        return apiTimes;
      }
    } catch (e) {
      print('Error fetching prayer times from API: $e');
    }

    // Fallback to local calculation using Adhan package
    return _calculatePrayerTimesLocally(
      latitude,
      longitude,
      date,
      useHanafiCalculation: useHanafiCalculation,
    );
  }

  static Future<Map<String, DateTime>?> _getPrayerTimesFromAPI(
    double latitude,
    double longitude,
    DateTime date, {
    bool useHanafiCalculation = false,
  }) async {
    try {
      // Use different school parameter for Hanafi calculation
      final schoolParam = useHanafiCalculation ? '&school=1' : '';

      final response = await http.get(
        Uri.parse(
          '$_apiBaseUrl/timings/${date.day}-${date.month}-${date.year}?latitude=$latitude&longitude=$longitude&method=2$schoolParam',
        ),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final timings = data['data']['timings'];

        return {
          'fajr': _parseTimeString(timings['Fajr'], date),
          'sunrise': _parseTimeString(timings['Sunrise'], date),
          'dhuhr': _parseTimeString(timings['Dhuhr'], date),
          'asr': _parseTimeString(timings['Asr'], date),
          'maghrib': _parseTimeString(timings['Maghrib'], date),
          'isha': _parseTimeString(timings['Isha'], date),
        };
      }
    } catch (e) {
      print('Error in API prayer times: $e');
    }
    return null;
  }

  static DateTime _parseTimeString(String timeString, DateTime date) {
    // Remove timezone info if present (e.g., "05:30 (+05)" -> "05:30")
    final cleanTime = timeString.split(' ')[0];
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static Map<String, DateTime> _calculatePrayerTimesLocally(
    double latitude,
    double longitude,
    DateTime date, {
    bool useHanafiCalculation = false,
  }) {
    // Use Adhan package for accurate local calculation
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.muslim_world_league.getParameters();

    // Adjust calculation parameters for better accuracy
    if (useHanafiCalculation) {
      params.madhab = Madhab.hanafi;
    } else {
      params.madhab = Madhab.shafi;
    }

    params.fajrAngle = 18.0;
    params.ishaAngle = 17.0;

    final prayerTimes = PrayerTimes.today(coordinates, params);

    return {
      'fajr': prayerTimes.fajr,
      'sunrise': prayerTimes.sunrise,
      'dhuhr': prayerTimes.dhuhr,
      'asr': prayerTimes.asr,
      'maghrib': prayerTimes.maghrib,
      'isha': prayerTimes.isha,
    };
  }

  static Future<void> _cachePrayerTimes(
    Map<String, DateTime> prayerTimes,
    DateTime date,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'prayer_times_${date.year}_${date.month}_${date.day}';

      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'date': '${date.year}-${date.month}-${date.day}',
        'times': prayerTimes.map(
          (key, value) => MapEntry(key, value.millisecondsSinceEpoch),
        ),
      };

      await prefs.setString(cacheKey, json.encode(cacheData));
    } catch (e) {
      print('Error caching prayer times: $e');
    }
  }

  // Get/Set Hanafi calculation preference
  static Future<bool> getHanafiCalculationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('use_hanafi_calculation') ?? false;
    } catch (e) {
      print('Error getting Hanafi calculation preference: $e');
      return false;
    }
  }

  static Future<void> setHanafiCalculationPreference(bool useHanafi) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_hanafi_calculation', useHanafi);
    } catch (e) {
      print('Error setting Hanafi calculation preference: $e');
    }
  }

  // Get next prayer and time remaining
  static Map<String, dynamic> getNextPrayer(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    final prayers = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];

    for (final prayer in prayers) {
      final prayerTime = prayerTimes[prayer]!;
      if (now.isBefore(prayerTime)) {
        final timeUntil = prayerTime.difference(now);
        return {
          'name': _capitalizeFirst(prayer),
          'time': prayerTime,
          'timeUntil': timeUntil,
          'formattedTimeUntil': _formatDuration(timeUntil),
        };
      }
    }

    // If no prayer today, get Fajr tomorrow
    final tomorrow = now.add(const Duration(days: 1));
    final tomorrowFajr = DateTime(
      tomorrow.year,
      tomorrow.month,
      tomorrow.day,
      prayerTimes['fajr']!.hour,
      prayerTimes['fajr']!.minute,
    );

    final timeUntil = tomorrowFajr.difference(now);
    return {
      'name': 'Fajr',
      'time': tomorrowFajr,
      'timeUntil': timeUntil,
      'formattedTimeUntil': _formatDuration(timeUntil),
    };
  }

  static String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  // Get current prayer
  static String getCurrentPrayer(Map<String, DateTime> prayerTimes) {
    final now = DateTime.now();
    final prayers = ['fajr', 'sunrise', 'dhuhr', 'asr', 'maghrib', 'isha'];

    String currentPrayer = 'Isha'; // Default to last prayer

    for (int i = 0; i < prayers.length; i++) {
      final prayerTime = prayerTimes[prayers[i]]!;
      if (now.isAfter(prayerTime)) {
        currentPrayer = _capitalizeFirst(prayers[i]);
      } else {
        break;
      }
    }

    return currentPrayer;
  }

  // Clear old cache entries
  static Future<void> clearOldCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final now = DateTime.now();

      for (final key in keys) {
        if (key.startsWith('prayer_times_')) {
          final cacheData = prefs.getString(key);
          if (cacheData != null) {
            final data = json.decode(cacheData);
            final cacheTimestamp = data['timestamp'] as int;
            final cacheAge = now.millisecondsSinceEpoch - cacheTimestamp;

            // Remove cache older than 7 days
            if (cacheAge > 604800000) {
              await prefs.remove(key);
            }
          }
        }
      }
    } catch (e) {
      print('Error cleaning prayer times cache: $e');
    }
  }
}
