import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/active_challenge_card_widget.dart';
import './widgets/challenge_card_widget.dart';
import './widgets/challenge_creation_sheet_widget.dart';
import './widgets/challenge_history_widget.dart';

class ChallengeMode extends StatefulWidget {
  const ChallengeMode({super.key});

  @override
  State<ChallengeMode> createState() => _ChallengeModeState();
}

class _ChallengeModeState extends State<ChallengeMode>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isCreatingChallenge = false;

  // Mock data for active challenges
  final List<Map<String, dynamic>> activeChallenges = [
    {
      "id": 1,
      "title": "100 SubhanAllah for 7 Days",
      "description": "Complete 100 SubhanAllah daily for a week",
      "type": "solo",
      "progress": 350,
      "target": 700,
      "currentDay": 4,
      "totalDays": 7,
      "participants": 1,
      "difficulty": "Medium",
      "estimatedTime": "15 min/day",
      "spiritualBenefit": "Purification of the heart and mind",
      "hadithQuote":
          "Whoever says 'SubhanAllah' 100 times, his sins are forgiven even if they are like the foam of the sea.",
      "isActive": true,
      "timeRemaining": "3 days left",
      "backgroundImage":
          "https://images.unsplash.com/photo-1542816417-0983c9c9ad53?fm=jpg&q=60&w=3000",
    },
    {
      "id": 2,
      "title": "Morning Dhikr Consistency",
      "description": "Perform morning Dhikr for 30 consecutive days",
      "type": "group",
      "progress": 12,
      "target": 30,
      "currentDay": 12,
      "totalDays": 30,
      "participants": 24,
      "difficulty": "Hard",
      "estimatedTime": "20 min/day",
      "spiritualBenefit": "Strengthening connection with Allah",
      "hadithQuote": "Remember Allah in the morning and evening.",
      "isActive": true,
      "timeRemaining": "18 days left",
      "backgroundImage":
          "https://images.unsplash.com/photo-1589186222872-418c38954ca3?q=80&w=986&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
    },
  ];

  // Mock data for available challenges
  final List<Map<String, dynamic>> availableChallenges = [
    {
      "id": 3,
      "title": "1000 Istighfar Challenge",
      "description": "Seek forgiveness 1000 times in one session",
      "type": "solo",
      "target": 1000,
      "difficulty": "Hard",
      "estimatedTime": "45 minutes",
      "spiritualBenefit": "Complete purification and forgiveness",
      "hadithQuote":
          "Whoever seeks forgiveness regularly, Allah will make a way out for him from every difficulty.",
      "backgroundImage":
          "https://images.unsplash.com/photo-1519904981063-b0cf448d479e?fm=jpg&q=60&w=3000",
    },
    {
      "id": 4,
      "title": "Weekly Salawat Challenge",
      "description":
          "Send blessings upon Prophet (PBUH) 500 times daily for a week",
      "type": "group",
      "target": 3500,
      "difficulty": "Medium",
      "estimatedTime": "25 min/day",
      "spiritualBenefit":
          "Increased love for the Prophet and spiritual elevation",
      "hadithQuote":
          "Whoever sends blessings upon me once, Allah will send blessings upon him ten times.",
      "backgroundImage":
          "https://images.unsplash.com/photo-1564769662533-4f00a87b4056?fm=jpg&q=60&w=3000",
    },
    {
      "id": 5,
      "title": "99 Names of Allah",
      "description": "Recite all 99 beautiful names of Allah daily for 21 days",
      "type": "solo",
      "target": 21,
      "difficulty": "Easy",
      "estimatedTime": "30 min/day",
      "spiritualBenefit": "Deep understanding of Allah's attributes",
      "hadithQuote":
          "Allah has 99 names, whoever memorizes them will enter Paradise.",
      "backgroundImage":
          "https://images.unsplash.com/photo-1578662996442-48f60103fc96?fm=jpg&q=60&w=3000",
    },
  ];

  // Mock data for challenge history
  final List<Map<String, dynamic>> challengeHistory = [
    {
      "id": 101,
      "title": "Ramadan Dhikr Marathon",
      "completedDate": "2024-04-10",
      "type": "group",
      "participants": 156,
      "achievement": "Golden Crescent",
      "totalDhikr": 5000,
      "duration": "30 days",
      "rank": 12,
    },
    {
      "id": 102,
      "title": "Daily Tasbih Challenge",
      "completedDate": "2024-03-15",
      "type": "solo",
      "participants": 1,
      "achievement": "Consistent Worshipper",
      "totalDhikr": 3300,
      "duration": "33 days",
      "rank": 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showChallengeCreationSheet() {
    setState(() {
      _isCreatingChallenge = true;
    });
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChallengeCreationSheetWidget(
        onClose: () {
          setState(() {
            _isCreatingChallenge = false;
          });
        },
      ),
    );
  }

  void _showChallengeDetails(Map<String, dynamic> challenge) {
    showDialog(
      context: context,
      builder: (context) => _buildChallengeDetailsDialog(challenge),
    );
  }

  Widget _buildChallengeDetailsDialog(Map<String, dynamic> challenge) {
    return Dialog(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: 80.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with background image
            Container(
              height: 25.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                image: DecorationImage(
                  image: NetworkImage(challenge["backgroundImage"] ?? ""),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 2.h,
                      right: 4.w,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2.h,
                      left: 4.w,
                      right: 4.w,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge["title"] ?? "",
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 1.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: challenge["type"] == "group"
                                      ? AppTheme
                                            .lightTheme
                                            .colorScheme
                                            .secondary
                                      : AppTheme.lightTheme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  challenge["type"] == "group"
                                      ? "Group"
                                      : "Solo",
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                    challenge["difficulty"],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  challenge["difficulty"] ?? "",
                                  style: AppTheme
                                      .lightTheme
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      challenge["description"] ?? "",
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 2.h),
                    if (challenge["isActive"] == true) ...[
                      Text(
                        "Progress",
                        style: AppTheme.lightTheme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 1.h),
                      LinearProgressIndicator(
                        value:
                            (challenge["progress"] ?? 0) /
                            (challenge["target"] ?? 1),
                        backgroundColor: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.lightTheme.colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        "${challenge["progress"]} / ${challenge["target"]} completed",
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      SizedBox(height: 2.h),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            "Duration",
                            challenge["estimatedTime"] ?? "",
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: _buildInfoCard(
                            "Participants",
                            "${challenge["participants"] ?? 0}",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Spiritual Benefit",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      challenge["spiritualBenefit"] ?? "",
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'format_quote',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                "Hadith",
                                style: AppTheme.lightTheme.textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            challenge["hadithQuote"] ?? "",
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Action buttons
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: challenge["isActive"] == true
                          ? null
                          : () {
                              Navigator.pop(context);
                              // Handle join challenge
                            },
                      child: Text(
                        challenge["isActive"] == true
                            ? "Active"
                            : "Join Challenge",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.lightTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.6,
              ),
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Challenge Mode",
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),

        actions: [
          IconButton(
            onPressed: _showChallengeCreationSheet,
            icon: CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'play_circle_filled',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text("Active"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'explore',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text("Explore"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'history',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text("History"),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Active Challenges Tab
          _buildActiveChallengesTab(),
          // Explore Challenges Tab
          _buildExploreChallengesTab(),
          // History Tab
          _buildHistoryTab(),
        ],
      ),
    );
  }

  Widget _buildActiveChallengesTab() {
    return activeChallenges.isEmpty
        ? _buildEmptyState(
            icon: 'play_circle_outline',
            title: "No Active Challenges",
            subtitle: "Join a challenge to start your spiritual journey",
            actionText: "Explore Challenges",
            onAction: () => _tabController.animateTo(1),
          )
        : ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: activeChallenges.length,
            itemBuilder: (context, index) {
              final challenge = activeChallenges[index];
              return ActiveChallengeCardWidget(
                challenge: challenge,
                onTap: () => _showChallengeDetails(challenge),
              );
            },
          );
  }

  Widget _buildExploreChallengesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(4.w),
      itemCount: availableChallenges.length,
      itemBuilder: (context, index) {
        final challenge = availableChallenges[index];
        return ChallengeCardWidget(
          challenge: challenge,
          onTap: () => _showChallengeDetails(challenge),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return challengeHistory.isEmpty
        ? _buildEmptyState(
            icon: 'history',
            title: "No Challenge History",
            subtitle: "Complete challenges to see your achievements here",
            actionText: "Start Challenge",
            onAction: () => _tabController.animateTo(1),
          )
        : ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: challengeHistory.length,
            itemBuilder: (context, index) {
              final challenge = challengeHistory[index];
              return ChallengeHistoryWidget(challenge: challenge);
            },
          );
  }

  Widget _buildEmptyState({
    required String icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.4,
              ),
              size: 64,
            ),
            SizedBox(height: 3.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              subtitle,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                  alpha: 0.6,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}
