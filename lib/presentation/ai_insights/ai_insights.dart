import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/dhikr_planner_widget.dart';
import './widgets/insight_card_widget.dart';
import './widgets/spiritual_reflection_widget.dart';

class AiInsights extends StatefulWidget {
  const AiInsights({super.key});

  @override
  State<AiInsights> createState() => _AiInsightsState();
}

class _AiInsightsState extends State<AiInsights> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // Mock AI insights data
  final List<Map<String, dynamic>> _aiInsights = [
    {
      "id": 1,
      "title": "Peak Dhikr Time Detected",
      "insight": "Your Dhikr activity peaks 30 minutes after Maghrib prayer",
      "confidence": 0.87,
      "category": "Pattern Analysis",
      "islamicContext":
          "The Prophet (PBUH) encouraged remembrance of Allah after prayers",
      "recommendation": "Consider extending your post-Maghrib Dhikr sessions",
      "supportingData": {
        "averageCount": 156,
        "timeRange": "19:30 - 20:00",
        "consistency": "85%",
      },
      "icon": "trending_up",
      "color": Color(0xFF4A7C59),
    },
    {
      "id": 2,
      "title": "Spiritual Consistency Growth",
      "insight": "Your daily Dhikr consistency has improved by 40% this month",
      "confidence": 0.92,
      "category": "Progress Tracking",
      "islamicContext":
          "Consistency in worship is beloved to Allah, even if small",
      "recommendation":
          "Maintain current routine and gradually increase counts",
      "supportingData": {
        "previousMonth": "60%",
        "currentMonth": "84%",
        "streak": "12 days",
      },
      "icon": "auto_graph",
      "color": Color(0xFF2D5A27),
    },
    {
      "id": 3,
      "title": "Optimal Dhikr Distribution",
      "insight":
          "Your SubhanAllah recitations are most effective during morning hours",
      "confidence": 0.78,
      "category": "Timing Optimization",
      "islamicContext": "Morning remembrance brings barakah to the entire day",
      "recommendation": "Focus SubhanAllah sessions between Fajr and sunrise",
      "supportingData": {
        "morningAverage": 89,
        "eveningAverage": 67,
        "effectiveness": "23% higher",
      },
      "icon": "wb_sunny",
      "color": Color(0xFFD4AF37),
    },
    {
      "id": 4,
      "title": "Social Motivation Impact",
      "insight": "Friend interactions increase your daily Dhikr by 35%",
      "confidence": 0.81,
      "category": "Social Analysis",
      "islamicContext":
          "Righteous companionship strengthens faith and practice",
      "recommendation":
          "Engage more with friends' Dhikr progress for mutual benefit",
      "supportingData": {
        "withFriends": 142,
        "withoutFriends": 105,
        "motivationBoost": "35%",
      },
      "icon": "people",
      "color": Color(0xFF8B4513),
    },
  ];

  // Mock planner suggestions
  final List<Map<String, dynamic>> _plannerSuggestions = [
    {
      "time": "05:30 - 06:00",
      "prayer": "After Fajr",
      "dhikr": "SubhanAllah",
      "count": 33,
      "reason": "Morning barakah period",
    },
    {
      "time": "13:15 - 13:30",
      "prayer": "After Dhuhr",
      "dhikr": "Alhamdulillah",
      "count": 25,
      "reason": "Midday spiritual reset",
    },
    {
      "time": "19:45 - 20:15",
      "prayer": "After Maghrib",
      "dhikr": "Allahu Akbar",
      "count": 50,
      "reason": "Your peak performance time",
    },
  ];

  // Mock reflection prompts
  final List<Map<String, dynamic>> _reflectionPrompts = [
    {
      "prompt":
          "Reflect on the meaning of 'SubhanAllah' - How does acknowledging Allah's perfection change your perspective today?",
      "category": "Meaning Contemplation",
      "duration": "5 minutes",
    },
    {
      "prompt":
          "Consider your intentions: Are you remembering Allah for His pleasure or for personal achievement?",
      "category": "Sincerity Check",
      "duration": "3 minutes",
    },
    {
      "prompt":
          "Think about gratitude: What specific blessings can you praise Allah for with 'Alhamdulillah' today?",
      "category": "Gratitude Focus",
      "duration": "7 minutes",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate AI processing time
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading ? _buildLoadingState() : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.primaryColor,
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomIconWidget(
                    iconName: 'arrow_back',
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  'AI Insights',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              CustomIconWidget(
                iconName: 'psychology',
                color: Colors.white.withValues(alpha: 0.8),
                size: 24,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'auto_awesome',
                  color: AppTheme.accentLight,
                  size: 20,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Personalized spiritual guidance powered by AI',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'Analyzing your spiritual patterns...',
            style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 2.h),
          _buildSectionHeader(
            'Your Insights',
            'Based on your Dhikr patterns',
            'insights',
          ),
          SizedBox(height: 1.h),
          _buildInsightsList(),
          SizedBox(height: 3.h),
          _buildSectionHeader(
            'AI Dhikr Planner',
            'Optimized schedule for your spiritual growth',
            'schedule',
          ),
          SizedBox(height: 1.h),
          DhikrPlannerWidget(suggestions: _plannerSuggestions),
          SizedBox(height: 3.h),
          _buildSectionHeader(
            'Spiritual Reflections',
            'Deepen your connection with Allah',
            'self_improvement',
          ),
          SizedBox(height: 1.h),
          SpiritualReflectionWidget(prompts: _reflectionPrompts),
          SizedBox(height: 2.h),
          _buildDisclaimerCard(),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, String iconName) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: AppTheme.lightTheme.primaryColor,
            size: 20,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                subtitle,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsightsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _aiInsights.length,
      separatorBuilder: (context, index) => SizedBox(height: 1.h),
      itemBuilder: (context, index) {
        final insight = _aiInsights[index];
        return InsightCardWidget(
          insight: insight,
          onTap: () => _showInsightDetails(insight),
        );
      },
    );
  }

  Widget _buildDisclaimerCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.warningLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.warningLight.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'info',
                color: AppTheme.warningLight,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Important Note',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.warningLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            'AI insights are supplementary tools for spiritual growth. Always prioritize traditional Islamic scholarship and consult qualified scholars for religious guidance. These recommendations are based on patterns and should not replace authentic Islamic teachings.',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showInsightDetails(Map<String, dynamic> insight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildInsightDetailsModal(insight),
    );
  }

  Widget _buildInsightDetailsModal(Map<String, dynamic> insight) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.dividerLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: (insight["color"] as Color).withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomIconWidget(
                          iconName: insight["icon"],
                          color: insight["color"],
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight["title"],
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              insight["category"],
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme.textSecondaryLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  _buildDetailSection('Insight', insight["insight"]),
                  SizedBox(height: 2.h),
                  _buildDetailSection(
                    'Islamic Context',
                    insight["islamicContext"],
                  ),
                  SizedBox(height: 2.h),
                  _buildDetailSection(
                    'Recommendation',
                    insight["recommendation"],
                  ),
                  SizedBox(height: 2.h),
                  _buildSupportingDataSection(insight["supportingData"]),
                  SizedBox(height: 2.h),
                  _buildConfidenceIndicator(insight["confidence"]),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          content,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildSupportingDataSection(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supporting Data',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: data.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 0.5.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key.replaceAll(RegExp(r'([A-Z])'), ' \$1').trim(),
                      style: AppTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(color: AppTheme.textSecondaryLight),
                    ),
                    Text(
                      entry.value.toString(),
                      style: AppTheme.lightTheme.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildConfidenceIndicator(double confidence) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AI Confidence',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(confidence * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.successLight,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: confidence,
          backgroundColor: AppTheme.lightTheme.primaryColor.withValues(
            alpha: 0.2,
          ),
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successLight),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
