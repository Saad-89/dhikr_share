import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class CalendarHeatmapWidget extends StatelessWidget {
  const CalendarHeatmapWidget({super.key});

  // Mock data for calendar heatmap
  final List<Map<String, dynamic>> _heatmapData = const [
    {"date": "2024-01-01", "intensity": 0.2},
    {"date": "2024-01-02", "intensity": 0.8},
    {"date": "2024-01-03", "intensity": 0.6},
    {"date": "2024-01-04", "intensity": 0.9},
    {"date": "2024-01-05", "intensity": 0.4},
    {"date": "2024-01-06", "intensity": 0.7},
    {"date": "2024-01-07", "intensity": 1.0},
    {"date": "2024-01-08", "intensity": 0.3},
    {"date": "2024-01-09", "intensity": 0.5},
    {"date": "2024-01-10", "intensity": 0.8},
    {"date": "2024-01-11", "intensity": 0.2},
    {"date": "2024-01-12", "intensity": 0.9},
    {"date": "2024-01-13", "intensity": 0.6},
    {"date": "2024-01-14", "intensity": 1.0},
    {"date": "2024-01-15", "intensity": 0.4},
    {"date": "2024-01-16", "intensity": 0.7},
    {"date": "2024-01-17", "intensity": 0.3},
    {"date": "2024-01-18", "intensity": 0.8},
    {"date": "2024-01-19", "intensity": 0.5},
    {"date": "2024-01-20", "intensity": 0.9},
    {"date": "2024-01-21", "intensity": 0.6},
    {"date": "2024-01-22", "intensity": 0.2},
    {"date": "2024-01-23", "intensity": 0.7},
    {"date": "2024-01-24", "intensity": 1.0},
    {"date": "2024-01-25", "intensity": 0.4},
    {"date": "2024-01-26", "intensity": 0.8},
    {"date": "2024-01-27", "intensity": 0.3},
    {"date": "2024-01-28", "intensity": 0.9},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        // border: Border.all(color: AppColors.grey, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                text: 'Activity Calendar',
                color: AppColors.black,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.start,
              ),
              Text(
                'Last 28 days',
                // style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                //   color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                //     alpha: 0.7,
                //   ),
                // ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildHeatmapGrid(),
          SizedBox(height: 10),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildHeatmapGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
        childAspectRatio: 1,
      ),
      itemCount: _heatmapData.length,
      itemBuilder: (context, index) {
        final data = _heatmapData[index];
        final intensity = data["intensity"] as double;

        return GestureDetector(
          onTap: () => _showDayDetails(data),
          child: Container(
            decoration: BoxDecoration(
              color: _getIntensityColor(intensity),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                // color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Center(
              child: intensity > 0.7
                  ? Icon(Icons.star, color: AppColors.white, size: 12)
                  : const SizedBox(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Less',
          // style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          //   color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
          //     alpha: 0.7,
          //   ),
          // ),
        ),
        Row(
          children: List.generate(5, (index) {
            final intensity = index / 4.0;
            return Container(
              width: 40,
              height: 40,
              margin: EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: _getIntensityColor(intensity),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  // color: AppTheme.lightTheme.dividerColor.withValues(
                  //   alpha: 0.3,
                  // ),
                  width: 0.5,
                ),
              ),
            );
          }),
        ),
        Text(
          'More',
          // style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          //   color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
          //     alpha: 0.7,
          //   ),
          // ),
        ),
      ],
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity == 0) {
      return AppColors.background;
    } else if (intensity <= 0.25) {
      return AppColors.primaryDarkGreen.withValues(alpha: 0.2);
    } else if (intensity <= 0.5) {
      return AppColors.primaryDarkGreen.withValues(alpha: 0.4);
    } else if (intensity <= 0.75) {
      return AppColors.primaryDarkGreen.withValues(alpha: 0.6);
    } else {
      return AppColors.primaryDarkGreen;
    }
  }

  void _showDayDetails(Map<String, dynamic> data) {
    // This would show a tooltip or modal with day details
    // For now, it's a placeholder
  }
}
