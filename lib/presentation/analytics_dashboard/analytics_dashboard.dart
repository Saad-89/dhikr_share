import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/analytics_card_widget.dart';
import './widgets/calendar_heatmap_widget.dart';
import './widgets/insight_card_widget.dart';
import './widgets/progress_ring_widget.dart';

class AnalyticsDashboard extends StatefulWidget {
  const AnalyticsDashboard({super.key});

  @override
  State<AnalyticsDashboard> createState() => _AnalyticsDashboardState();
}

class _AnalyticsDashboardState extends State<AnalyticsDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0: Daily, 1: Weekly, 2: Monthly, 3: Yearly

  final List<String> _periods = ['Daily', 'Weekly', 'Monthly', 'Yearly'];

  // Mock data for analytics
  final Map<String, dynamic> _analyticsData = {
    "currentStreak": 15,
    "totalDhikrToday": 247,
    "dailyGoal": 300,
    "dhikrCounts": {"SubhanAllah": 89, "Alhamdulillah": 76, "Allahu Akbar": 82},
    "peakTimes": [
      {"time": "After Fajr", "count": 45},
      {"time": "After Maghrib", "count": 67},
      {"time": "Before Sleep", "count": 38},
    ],
    "weeklyProgress": [
      {"day": "Mon", "count": 234},
      {"day": "Tue", "count": 189},
      {"day": "Wed", "count": 267},
      {"day": "Thu", "count": 198},
      {"day": "Fri", "count": 345},
      {"day": "Sat", "count": 278},
      {"day": "Sun", "count": 247},
    ],
    "insights": [
      "Most active after Fajr prayer - Keep up the blessed routine!",
      "Consistent evening Dhikr shows spiritual dedication",
      "Friday shows highest engagement - Barakallahu feeki",
    ],
    "improvements": {"weekOverWeek": "+23%", "monthOverMonth": "+15%"},
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreakHeader(),
                  SizedBox(height: 3.h),
                  _buildProgressRings(),
                  SizedBox(height: 3.h),
                  _buildDhikrCountsChart(),
                  SizedBox(height: 3.h),
                  _buildPeakTimesChart(),
                  SizedBox(height: 3.h),
                  _buildWeeklyProgressChart(),
                  SizedBox(height: 3.h),
                  CalendarHeatmapWidget(),
                  SizedBox(height: 3.h),
                  _buildInsightsSection(),
                  SizedBox(height: 3.h),
                  _buildComparisonCards(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Analytics Dashboard',
        style: AppTheme.lightTheme.textTheme.titleLarge,
      ),
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: _showExportOptions,
          icon: CustomIconWidget(
            iconName: 'share',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
        ),
        SizedBox(width: 2.w),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.dividerColor, width: 1),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.primaryColor
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStreakHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Current Streak',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            '${_analyticsData["currentStreak"]} Days',
            style: AppTheme.dhikrCounterStyle(isLight: true).copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary,
              fontSize: 36.sp,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Alhamdulillahi Rabbil Alameen',
            style: AppTheme.arabicTextStyle(isLight: true).copyWith(
              color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                alpha: 0.9,
              ),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRings() {
    final totalToday = _analyticsData["totalDhikrToday"] as int;
    final dailyGoal = _analyticsData["dailyGoal"] as int;
    final progress = (totalToday / dailyGoal).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: ProgressRingWidget(
            progress: progress,
            title: 'Daily Goal',
            subtitle: '$totalToday / $dailyGoal',
            color: AppTheme.lightTheme.primaryColor,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: ProgressRingWidget(
            progress: 0.75,
            title: 'Weekly Goal',
            subtitle: '1,847 / 2,100',
            color: AppTheme.lightTheme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDhikrCountsChart() {
    final dhikrCounts = _analyticsData["dhikrCounts"] as Map<String, dynamic>;

    return AnalyticsCardWidget(
      title: 'Dhikr Distribution',
      child: SizedBox(
        height: 30.h,
        child: PieChart(
          PieChartData(
            sections: dhikrCounts.entries.map((entry) {
              final colors = [
                AppTheme.lightTheme.primaryColor,
                AppTheme.lightTheme.colorScheme.secondary,
                AppTheme.lightTheme.colorScheme.tertiary,
              ];
              final index = dhikrCounts.keys.toList().indexOf(entry.key);

              return PieChartSectionData(
                value: (entry.value as int).toDouble(),
                title: '${entry.value}',
                color: colors[index % colors.length],
                radius: 60,
                titleStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
            centerSpaceRadius: 40,
            sectionsSpace: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildPeakTimesChart() {
    final peakTimes = _analyticsData["peakTimes"] as List;

    return AnalyticsCardWidget(
      title: 'Peak Activity Times',
      child: SizedBox(
        height: 25.h,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: 80,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < peakTimes.length) {
                      return Padding(
                        padding: EdgeInsets.only(top: 1.h),
                        child: Text(
                          peakTimes[index]["time"],
                          style: AppTheme.lightTheme.textTheme.labelSmall,
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: peakTimes.asMap().entries.map((entry) {
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: (entry.value["count"] as int).toDouble(),
                    color: AppTheme.lightTheme.primaryColor,
                    width: 8.w,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildWeeklyProgressChart() {
    final weeklyProgress = _analyticsData["weeklyProgress"] as List;

    return AnalyticsCardWidget(
      title: 'Weekly Progress',
      child: SizedBox(
        height: 25.h,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index >= 0 && index < weeklyProgress.length) {
                      return Text(
                        weeklyProgress[index]["day"],
                        style: AppTheme.lightTheme.textTheme.labelSmall,
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: weeklyProgress.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    (entry.value["count"] as int).toDouble(),
                  );
                }).toList(),
                isCurved: true,
                color: AppTheme.lightTheme.primaryColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppTheme.lightTheme.primaryColor,
                      strokeWidth: 2,
                      strokeColor: AppTheme.lightTheme.colorScheme.surface,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    final insights = _analyticsData["insights"] as List<String>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI Insights', style: AppTheme.lightTheme.textTheme.titleMedium),
        SizedBox(height: 2.h),
        ...insights.map((insight) => InsightCardWidget(insight: insight)),
      ],
    );
  }

  Widget _buildComparisonCards() {
    final improvements = _analyticsData["improvements"] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Comparison',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                'Week over Week',
                improvements["weekOverWeek"],
                'Subhan Allah! Great improvement',
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildComparisonCard(
                'Month over Month',
                improvements["monthOverMonth"],
                'Consistent growth, Masha Allah',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComparisonCard(String title, String percentage, String message) {
    final isPositive = percentage.startsWith('+');

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.lightTheme.dividerColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTheme.lightTheme.textTheme.labelMedium),
          SizedBox(height: 1.h),
          Row(
            children: [
              CustomIconWidget(
                iconName: isPositive ? 'trending_up' : 'trending_down',
                color: isPositive
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.error,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                percentage,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: isPositive
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            message,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: 2, // Analytics tab active
      selectedItemColor: AppTheme.lightTheme.primaryColor,
      unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurface.withValues(
        alpha: 0.6,
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'home',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
            size: 24,
          ),
          activeIcon: CustomIconWidget(
            iconName: 'home',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'people',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
            size: 24,
          ),
          activeIcon: CustomIconWidget(
            iconName: 'people',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          label: 'Friends',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          label: 'Analytics',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'emoji_events',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
            size: 24,
          ),
          activeIcon: CustomIconWidget(
            iconName: 'emoji_events',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          label: 'Challenges',
        ),
        BottomNavigationBarItem(
          icon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.6,
            ),
            size: 24,
          ),
          activeIcon: CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.lightTheme.primaryColor,
            size: 24,
          ),
          label: 'Settings',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/main-dhikr-counter');
            break;
          case 1:
            Navigator.pushNamed(context, '/friends-list');
            break;
          case 2:
            // Already on analytics dashboard
            break;
          case 3:
            Navigator.pushNamed(context, '/challenge-mode');
            break;
          case 4:
            Navigator.pushNamed(context, '/settings');
            break;
        }
      },
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Export Analytics',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'share',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Share Summary'),
              subtitle: Text('Share with friends or mentor'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'download',
                color: AppTheme.lightTheme.primaryColor,
                size: 24,
              ),
              title: Text('Download PDF'),
              subtitle: Text('Save detailed report'),
              onTap: () {
                Navigator.pop(context);
                // Implement PDF export
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
