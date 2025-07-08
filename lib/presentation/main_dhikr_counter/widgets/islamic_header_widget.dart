import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/islamic_calendar_service.dart';
import '../../../services/location_service.dart';
import '../../../services/prayer_time_service.dart';

class IslamicHeaderWidget extends StatefulWidget {
  const IslamicHeaderWidget({super.key});

  @override
  State<IslamicHeaderWidget> createState() => _IslamicHeaderWidgetState();
}

class _IslamicHeaderWidgetState extends State<IslamicHeaderWidget> {
  String _currentHijriDate = "Loading...";
  String _nextPrayer = "---";
  String _timeUntilPrayer = "--:--:--";
  String? _islamicEvent;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadIslamicData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updatePrayerTime();
    });
  }

  Future<void> _loadIslamicData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load Islamic date
      final islamicDate = await IslamicCalendarService.getCurrentIslamicDate();
      final formattedDate = IslamicCalendarService.formatIslamicDate(
        islamicDate,
      );

      // Check for significant Islamic events
      final event = await IslamicCalendarService.getSignificantIslamicEvent();

      setState(() {
        _currentHijriDate = formattedDate;
        _islamicEvent = event;
      });

      // Load prayer times and update next prayer
      await _loadPrayerTimes();
    } catch (e) {
      print('Error loading Islamic data: $e');
      setState(() {
        _currentHijriDate = "Unable to load date";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble('user_latitude');
      final longitude = prefs.getDouble('user_longitude');

      if (latitude != null && longitude != null) {
        final prayerTimes = await PrayerTimeService.calculatePrayerTimes(
          latitude,
          longitude,
          DateTime.now(),
        );

        final nextPrayerInfo = PrayerTimeService.getNextPrayer(prayerTimes);

        setState(() {
          _nextPrayer = nextPrayerInfo['name'];
          _timeUntilPrayer = nextPrayerInfo['formattedTimeUntil'];
        });
      } else {
        // Try to get location if not set
        _requestLocation();
      }
    } catch (e) {
      print('Error loading prayer times: $e');
    }
  }

  Future<void> _requestLocation() async {
    try {
      final locationInfo = await LocationService.getLocationInfo();
      if (locationInfo != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_latitude', locationInfo['latitude']);
        await prefs.setDouble('user_longitude', locationInfo['longitude']);
        await prefs.setString('user_city', locationInfo['city']);

        // Reload prayer times with new location
        await _loadPrayerTimes();
      }
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _updatePrayerTime() {
    // This method updates the countdown timer
    _loadPrayerTimes();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Hijri Date with loading state
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'calendar_today',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              _isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                    )
                  : Text(
                      _currentHijriDate,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ],
          ),

          // Islamic Event (if any)
          if (_islamicEvent != null) ...[
            SizedBox(height: 0.5.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.secondary.withValues(
                    alpha: 0.3,
                  ),
                ),
              ),
              child: Text(
                _islamicEvent!,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          SizedBox(height: 1.h),

          // Next Prayer Countdown with refresh button
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.3,
                ),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'access_time',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                SizedBox(width: 2.w),
                Text(
                  '$_nextPrayer in $_timeUntilPrayer',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 2.w),
                InkWell(
                  onTap: _loadIslamicData,
                  child: CustomIconWidget(
                    iconName: 'refresh',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Bismillah
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
            style: AppTheme.arabicTextStyle(isLight: true).copyWith(
              fontSize: 16.sp,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
