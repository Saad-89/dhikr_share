import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IslamicCalendarService {
  static const String _baseUrl = 'https://api.aladhan.com/v1';
  static const List<String> _islamicMonths = [
    'Muharram',
    'Safar',
    'Rabi\' al-awwal',
    'Rabi\' al-thani',
    'Jumada al-awwal',
    'Jumada al-thani',
    'Rajab',
    'Sha\'ban',
    'Ramadan',
    'Shawwal',
    'Dhu al-Qi\'dah',
    'Dhu al-Hijjah',
  ];

  // Get current Islamic date from API with fallback to calculation
  static Future<Map<String, dynamic>> getCurrentIslamicDate() async {
    try {
      // Try to get from API first for accuracy
      final response = await http.get(
        Uri.parse('$_baseUrl/gToH'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hijriData = data['data']['hijri'];

        final islamicDate = {
          'day': int.parse(hijriData['day']),
          'month': hijriData['month']['number'],
          'monthName': hijriData['month']['en'],
          'year': int.parse(hijriData['year']),
          'weekday': hijriData['weekday']['en'],
          'designation': hijriData['designation']['abbreviated'], // AH
        };

        // Cache the result
        await _cacheIslamicDate(islamicDate);
        return islamicDate;
      }
    } catch (e) {
      print('Error fetching Islamic date from API: $e');
    }

    // Fallback to cached data or local calculation
    return await _getCachedOrCalculatedDate();
  }

  // Enhanced local calculation as fallback
  static Future<Map<String, dynamic>> _getCachedOrCalculatedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedDate = prefs.getString('cached_islamic_date');
      final cacheTimestamp = prefs.getInt('islamic_date_cache_timestamp');

      // Check if cache is valid (less than 24 hours old)
      if (cachedDate != null && cacheTimestamp != null) {
        final cacheAge = DateTime.now().millisecondsSinceEpoch - cacheTimestamp;
        if (cacheAge < 86400000) {
          // 24 hours in milliseconds
          return json.decode(cachedDate);
        }
      }
    } catch (e) {
      print('Error reading cached Islamic date: $e');
    }

    // Calculate locally if no valid cache
    return _calculateIslamicDate(DateTime.now());
  }

  static Future<void> _cacheIslamicDate(
    Map<String, dynamic> islamicDate,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_islamic_date', json.encode(islamicDate));
      await prefs.setInt(
        'islamic_date_cache_timestamp',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      print('Error caching Islamic date: $e');
    }
  }

  // Improved calculation method
  static Map<String, dynamic> _calculateIslamicDate(DateTime gregorianDate) {
    // More accurate conversion using the Hijri calendar
    // Reference: 1 Muharram 1 AH = July 16, 622 CE
    final hijraEpoch = DateTime(622, 7, 16);
    final daysSinceHijra = gregorianDate.difference(hijraEpoch).inDays;

    // More precise Islamic year calculation (354.367 days per Islamic year)
    const double islamicYearLength = 354.367;
    final islamicYear = (daysSinceHijra / islamicYearLength).floor() + 1;

    // Calculate remaining days in the current Islamic year
    final remainingDays = (daysSinceHijra % islamicYearLength).floor();

    // Islamic months with alternating 29/30 days
    // In leap years, the last month has 30 days instead of 29
    final isLeapYear = ((islamicYear * 11) % 30) < 11;
    final monthLengths = [
      30,
      29,
      30,
      29,
      30,
      29,
      30,
      29,
      30,
      29,
      30,
      isLeapYear ? 30 : 29,
    ];

    int month = 1;
    int day = remainingDays + 1;
    int totalDays = 0;

    for (int i = 0; i < 12; i++) {
      if (totalDays + monthLengths[i] >= day) {
        month = i + 1;
        day = day - totalDays;
        break;
      }
      totalDays += monthLengths[i];
    }

    // Ensure day is within valid range
    day = day.clamp(1, monthLengths[month - 1]);

    return {
      'day': day,
      'month': month,
      'monthName': getIslamicMonthName(month),
      'year': islamicYear,
      'weekday': _getIslamicWeekday(gregorianDate.weekday),
      'designation': 'AH',
    };
  }

  static String _getIslamicWeekday(int gregorianWeekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[(gregorianWeekday - 1) % 7];
  }

  static String getIslamicMonthName(int month) {
    if (month < 1 || month > 12) return '';
    return _islamicMonths[month - 1];
  }

  static String formatIslamicDate(Map<String, dynamic> islamicDate) {
    final day = islamicDate['day'];
    final monthName = islamicDate['monthName'];
    final year = islamicDate['year'];
    final designation = islamicDate['designation'] ?? 'AH';

    return '$day $monthName $year $designation';
  }

  // Get specific Islamic date for any Gregorian date
  static Future<Map<String, dynamic>> getIslamicDateFor(
    DateTime gregorianDate,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$_baseUrl/gToH/${gregorianDate.day}-${gregorianDate.month}-${gregorianDate.year}',
        ),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final hijriData = data['data']['hijri'];

        return {
          'day': int.parse(hijriData['day']),
          'month': hijriData['month']['number'],
          'monthName': hijriData['month']['en'],
          'year': int.parse(hijriData['year']),
          'weekday': hijriData['weekday']['en'],
          'designation': hijriData['designation']['abbreviated'],
        };
      }
    } catch (e) {
      print('Error fetching Islamic date for specific date: $e');
    }

    // Fallback to calculation
    return _calculateIslamicDate(gregorianDate);
  }

  // Check if current date is a significant Islamic date
  static Future<String?> getSignificantIslamicEvent() async {
    final islamicDate = await getCurrentIslamicDate();
    final month = islamicDate['month'];
    final day = islamicDate['day'];

    // Define significant Islamic dates
    final significantDates = {
      '1-1': 'Islamic New Year (Muharram 1)',
      '1-10': 'Day of Ashura',
      '3-12': 'Mawlid an-Nabi (Prophet\'s Birthday)',
      '7-27': 'Isra and Mi\'raj',
      '8-15': 'Mid-Sha\'ban',
      '9-1': 'First Day of Ramadan',
      '9-27': 'Laylat al-Qadr (Night of Power)',
      '10-1': 'Eid al-Fitr',
      '12-8': 'Day of Arafah',
      '12-10': 'Eid al-Adha',
    };

    final key = '$month-$day';
    return significantDates[key];
  }

  // Clear cache (useful for testing or manual refresh)
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_islamic_date');
      await prefs.remove('islamic_date_cache_timestamp');
    } catch (e) {
      print('Error clearing Islamic date cache: $e');
    }
  }
}
