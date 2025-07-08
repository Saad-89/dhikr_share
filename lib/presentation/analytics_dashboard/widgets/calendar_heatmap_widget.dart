import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.lightTheme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Activity Calendar',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Last 28 days',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildHeatmapGrid(),
          SizedBox(height: 2.h),
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
        crossAxisSpacing: 1.w,
        mainAxisSpacing: 1.w,
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
                color: AppTheme.lightTheme.dividerColor.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Center(
              child: intensity > 0.7
                  ? CustomIconWidget(
                      iconName: 'star',
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                      size: 12,
                    )
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
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
        ),
        Row(
          children: List.generate(5, (index) {
            final intensity = index / 4.0;
            return Container(
              width: 4.w,
              height: 4.w,
              margin: EdgeInsets.symmetric(horizontal: 0.5.w),
              decoration: BoxDecoration(
                color: _getIntensityColor(intensity),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: AppTheme.lightTheme.dividerColor.withValues(
                    alpha: 0.3,
                  ),
                  width: 0.5,
                ),
              ),
            );
          }),
        ),
        Text(
          'More',
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
        ),
      ],
    );
  }

  Color _getIntensityColor(double intensity) {
    if (intensity == 0) {
      return AppTheme.lightTheme.colorScheme.surface;
    } else if (intensity <= 0.25) {
      return AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2);
    } else if (intensity <= 0.5) {
      return AppTheme.lightTheme.primaryColor.withValues(alpha: 0.4);
    } else if (intensity <= 0.75) {
      return AppTheme.lightTheme.primaryColor.withValues(alpha: 0.6);
    } else {
      return AppTheme.lightTheme.primaryColor;
    }
  }

  void _showDayDetails(Map<String, dynamic> data) {
    // This would show a tooltip or modal with day details
    // For now, it's a placeholder
  }
}
