import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/location_service.dart';
import '../../../services/prayer_time_service.dart';

class PrayerTimesWidget extends StatefulWidget {
  const PrayerTimesWidget({super.key});

  @override
  State<PrayerTimesWidget> createState() => _PrayerTimesWidgetState();
}

class _PrayerTimesWidgetState extends State<PrayerTimesWidget> {
  Map<String, DateTime>? _prayerTimes;
  String? _userCity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final latitude = prefs.getDouble('user_latitude');
      final longitude = prefs.getDouble('user_longitude');
      final city = prefs.getString('user_city');

      if (latitude != null && longitude != null) {
        final prayerTimes = await PrayerTimeService.calculatePrayerTimes(
          latitude,
          longitude,
          DateTime.now(),
        );

        setState(() {
          _prayerTimes = prayerTimes;
          _userCity = city;
        });
      }
    } catch (e) {
      print('Error loading prayer times: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final locationInfo = await LocationService.getLocationInfo();

      if (locationInfo != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_latitude', locationInfo['latitude']);
        await prefs.setDouble('user_longitude', locationInfo['longitude']);
        await prefs.setString('user_city', locationInfo['city']);

        await _loadPrayerTimes();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated successfully!'),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update location'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour > 12
        ? time.hour - 12
        : time.hour == 0
            ? 12
            : time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow.withValues(
              alpha: 0.1,
            ),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    SizedBox(width: 3.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Prayer Times',
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        if (_userCity != null)
                          Text(
                            'Location: $_userCity',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _isLoading ? null : _updateLocation,
                  icon: _isLoading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'refresh',
                          color: AppTheme.lightTheme.colorScheme.primary,
                          size: 20,
                        ),
                ),
              ],
            ),
          ),

          // Prayer Times List
          if (_prayerTimes != null)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  _buildPrayerTimeRow('Fajr', _prayerTimes!['fajr']!),
                  _buildPrayerTimeRow('Sunrise', _prayerTimes!['sunrise']!),
                  _buildPrayerTimeRow('Dhuhr', _prayerTimes!['dhuhr']!),
                  _buildPrayerTimeRow('Asr', _prayerTimes!['asr']!),
                  _buildPrayerTimeRow('Maghrib', _prayerTimes!['maghrib']!),
                  _buildPrayerTimeRow('Isha', _prayerTimes!['isha']!),
                ],
              ),
            )
          else if (!_isLoading)
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                children: [
                  CustomIconWidget(
                    iconName: 'location_off',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 32,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Location not set',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Please allow location access to view prayer times',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    onPressed: _updateLocation,
                    icon: CustomIconWidget(
                      iconName: 'location_on',
                      color: Colors.white,
                      size: 18,
                    ),
                    label: Text('Set Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(String prayerName, DateTime time) {
    final now = DateTime.now();
    final isCurrentPrayer =
        now.hour == time.hour && (now.minute - time.minute).abs() < 30;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isCurrentPrayer
            ? AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1)
            : AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPrayer
              ? AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.3,
                )
              : AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.2,
                ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            prayerName,
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: isCurrentPrayer ? FontWeight.w600 : FontWeight.w500,
              color: isCurrentPrayer
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          Text(
            _formatTime(time),
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: isCurrentPrayer
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
