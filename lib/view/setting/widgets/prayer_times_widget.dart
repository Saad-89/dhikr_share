import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class PrayerTimesWidget extends StatelessWidget {
  const PrayerTimesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final dummyCity = 'Karachi';
    final dummyPrayerTimes = {
      'Fajr': '4:30 AM',
      'Sunrise': '5:50 AM',
      'Dhuhr': '12:15 PM',
      'Asr': '3:45 PM',
      'Maghrib': '6:55 PM',
      'Isha': '8:10 PM',
    };

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.schedule,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AppText(
                          text: 'Prayer Times',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                        AppText(
                          text: 'Location: $dummyCity',
                          fontSize: 13,
                          fontWeight: FontWeight.normal,
                          color: AppColors.black54,
                        ),
                      ],
                    ),
                  ],
                ),
                const Icon(
                  Icons.refresh,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ],
            ),
          ),

          // Dummy Prayer Times
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: dummyPrayerTimes.entries.map((entry) {
                return _buildPrayerTimeRow(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimeRow(String prayerName, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AppText(
            text: prayerName,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          AppText(
            text: time,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
