import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import './widgets/analytics_card_widget.dart';
import './widgets/calendar_heatmap_widget.dart';
import './widgets/insight_card_widget.dart';
import './widgets/progress_ring_widget.dart';

class AnalyticsDashboard extends StatefulWidget {
  final bool? friendsAnalyticScreen;
  const AnalyticsDashboard({super.key, this.friendsAnalyticScreen = false});

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
      backgroundColor: AppColors.menuBackGroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildPeriodSelector(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStreakHeader(),
                  const SizedBox(height: 24),
                  _buildProgressRings(),
                  const SizedBox(height: 24),
                  _buildDhikrCountsChart(),
                  const SizedBox(height: 24),
                  _buildPeakTimesChart(),
                  const SizedBox(height: 24),
                  _buildWeeklyProgressChart(),
                  const SizedBox(height: 24),
                  CalendarHeatmapWidget(),
                  const SizedBox(height: 24),
                  _buildInsightsSection(),
                  const SizedBox(height: 24),
                  _buildComparisonCards(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      automaticallyImplyLeading: widget.friendsAnalyticScreen! ? false : true,
      title: const AppText(text: 'Analytics Dashboard'),
      backgroundColor: AppColors.menuBackGroundColor,

      // elevation: 0,
      actions: [
        IconButton(
          onPressed: _showExportOptions,
          icon: Icon(Icons.share, color: AppColors.primaryDarkGreen, size: 24),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: AppColors.grey, width: 1),
      ),
      child: Row(
        children: List.generate(_periods.length, (index) {
          final isSelected = _selectedPeriod == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedPeriod = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _periods[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? AppColors.black : AppColors.black54,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,

        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text('Current Streak', style: TextStyle(color: AppColors.white)),
          const SizedBox(height: 8),
          Text(
            '${_analyticsData["currentStreak"]} Days',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Alhamdulillahi Rabbil Alameen',
            style: TextStyle(color: AppColors.white, fontSize: 14),
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
            color: AppColors.primaryDarkGreen,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProgressRingWidget(
            progress: 0.75,
            title: 'Weekly Goal',
            subtitle: '1,847 / 2,100',
            color: AppColors.brownColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDhikrCountsChart() {
    final dhikrCounts = _analyticsData["dhikrCounts"] as Map<String, dynamic>;

    // Define colors and labels to match the image
    final chartData = [
      {'label': 'Tasbih', 'value': 89, 'color': AppColors.primaryDarkGreen},
      {
        'label': 'Tahmid',
        'value': 82,
        'color': const Color(0xFFD4AF37),
      }, // Golden color
      {
        'label': 'Takbir',
        'value': 76,
        'color': const Color(0xFF8B4513),
      }, // Brown color
    ];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
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
              Text(
                'Dhikr Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDarkGreen,
                ),
              ),
              Icon(
                Icons.more_vert,
                color: AppColors.primaryDarkGreen,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Pie Chart
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: chartData.map((data) {
                        return PieChartSectionData(
                          value: (data['value'] as int).toDouble(),
                          title: '${data['value']}',
                          color: data['color'] as Color,
                          radius: 60,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                      centerSpaceRadius: 40,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 30),
              // Legend
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: chartData.map((data) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: data['color'] as Color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            data['label'] as String,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeakTimesChart() {
    final peakTimes = _analyticsData["peakTimes"] as List;

    return AnalyticsCardWidget(
      title: 'Peak Activity Times',
      child: SizedBox(
        height: 200,
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
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          peakTimes[index]["time"],
                          style: const TextStyle(fontSize: 10),
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
                    color: AppColors.primaryDarkGreen,
                    width: 32,
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
        height: 200,
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
                      return Text(weeklyProgress[index]["day"]);
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
                color: AppColors.primaryDarkGreen,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.primaryDarkGreen,
                      strokeWidth: 2,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.primaryDarkGreen.withOpacity(0.1),
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
        const Text(
          'AI Insights',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...insights.map((insight) => InsightCardWidget(insight: insight)),
      ],
    );
  }

  Widget _buildComparisonCards() {
    final improvements = _analyticsData["improvements"] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Progress Comparison',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildComparisonCard(
                'Week over Week',
                improvements["weekOverWeek"],
                'Subhan Allah! Great improvement',
              ),
            ),
            const SizedBox(width: 16),
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
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
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                color: isPositive ? AppColors.primaryDarkGreen : AppColors.red,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                percentage,
                style: TextStyle(
                  color: isPositive
                      ? AppColors.primaryDarkGreen
                      : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(color: AppColors.primaryDarkGreen, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showExportOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.black54,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Export Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(
                Icons.share,
                color: AppColors.primaryDarkGreen,
                size: 24,
              ),
              title: const Text('Share Summary'),
              subtitle: const Text('Share with friends or mentor'),
              onTap: () {
                Navigator.pop(context);
                // Implement share functionality
              },
            ),
            ListTile(
              leading: Icon(
                Icons.download,
                color: AppColors.primaryDarkGreen,
                size: 24,
              ),
              title: const Text('Download PDF'),
              subtitle: const Text('Save detailed report'),
              onTap: () {
                Navigator.pop(context);
                // Implement PDF export
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
