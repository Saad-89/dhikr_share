import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class PrayerSettingsWidget extends StatefulWidget {
  final bool isPrayerTimesEnabled;
  final bool isHanafiCalculationEnabled;
  final String currentLocation;
  final Map<String, String> prayerTimes;
  final Function(bool)? onPrayerTimesToggle;
  final Function(bool)? onHanafiToggle;
  final VoidCallback? onRefreshTimes;

  const PrayerSettingsWidget({
    super.key,
    this.isPrayerTimesEnabled = true,
    this.isHanafiCalculationEnabled = true,
    this.currentLocation = 'Toronto',
    this.prayerTimes = const {
      'Fajr': '4:03 AM',
      'Sunrise': '5:30 AM',
      'Dhuhr': '12:15 PM',
      'Asr': '3:30 PM',
      'Maghrib': '6:45 PM',
      'Isha': '8:15 PM',
    },
    this.onPrayerTimesToggle,
    this.onHanafiToggle,
    this.onRefreshTimes,
  });

  @override
  State<PrayerSettingsWidget> createState() => _PrayerSettingsWidgetState();
}

class _PrayerSettingsWidgetState extends State<PrayerSettingsWidget> {
  late bool _isPrayerTimesEnabled;
  late bool _isHanafiCalculationEnabled;

  @override
  void initState() {
    super.initState();
    _isPrayerTimesEnabled = widget.isPrayerTimesEnabled;
    _isHanafiCalculationEnabled = widget.isHanafiCalculationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Settings Container
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Prayer Times Toggle
              _buildPrayerTimesToggle(),

              // Divider
              _buildDivider(),

              // Hanafi Calculation Toggle
              _buildHanafiCalculationToggle(),

              // Divider
              _buildDivider(),

              // Prayer Times Display
              _buildPrayerTimesDisplay(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerTimesToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.access_time,
                color: AppColors.primaryDarkGreen,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: 'Prayer Times',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                const SizedBox(height: 2),
                const AppText(
                  text: 'Show prayer times in the app',
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: AppColors.black54,
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isPrayerTimesEnabled,
              onChanged: (value) {
                setState(() {
                  _isPrayerTimesEnabled = value;
                });
                widget.onPrayerTimesToggle?.call(value);
              },
              activeColor: AppColors.primaryDarkGreen,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHanafiCalculationToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFE8F5E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Icon(
                Icons.schedule,
                color: AppColors.primaryDarkGreen,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: 'Hanafi Calculation for Asr',
                  textAlign: TextAlign.start,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                const SizedBox(height: 2),
                const AppText(
                  textAlign: TextAlign.start,
                  text:
                      'Hanafi school calculates Asr when\nshadow length equals object\nheight plus original shadow',
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                  color: AppColors.black54,
                  // maxLines: 3,
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isHanafiCalculationEnabled,
              onChanged: (value) {
                setState(() {
                  _isHanafiCalculationEnabled = value;
                });
                widget.onHanafiToggle?.call(value);
              },
              activeColor: AppColors.primaryDarkGreen,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.3),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesDisplay() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppText(
                text: 'Prayer Times',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              Row(
                children: [
                  AppText(
                    text: 'Location: ${widget.currentLocation}',
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                    color: AppColors.black54,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: widget.onRefreshTimes,
                    child: Icon(
                      Icons.refresh,
                      color: AppColors.black54,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Prayer Times List
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: widget.prayerTimes.entries.map((entry) {
                return _buildPrayerTimeRow(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(String prayerName, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: prayerName,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          AppText(
            text: time,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      endIndent: 16,
      color: AppColors.black54.withOpacity(0.3),
    );
  }
}
