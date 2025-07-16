import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with background image
            Container(
              height: 200,
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
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: Colors.white, size: 24),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge["title"] ?? "",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: challenge["type"] == "group"
                                      ? AppColors.primaryDarkGreen
                                      : AppColors.primaryGreen,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  challenge["type"] == "group"
                                      ? "Group"
                                      : "Solo",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                    challenge["difficulty"],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  challenge["difficulty"] ?? "",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
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
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      challenge["description"] ?? "",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    if (challenge["isActive"] == true) ...[
                      Text(
                        "Progress",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      LinearProgressIndicator(
                        value:
                            (challenge["progress"] ?? 0) /
                            (challenge["target"] ?? 1),
                        backgroundColor: AppColors.primaryGreen.withOpacity(
                          0.2,
                        ),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryGreen,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "${challenge["progress"]} / ${challenge["target"]} completed",
                        style: TextStyle(fontSize: 14),
                      ),
                      SizedBox(height: 16),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoCard(
                            "Duration",
                            challenge["estimatedTime"] ?? "",
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoCard(
                            "Participants",
                            "${challenge["participants"] ?? 0}",
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      "Spiritual Benefit",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      challenge["spiritualBenefit"] ?? "",
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.format_quote,
                                color: AppColors.primaryDarkGreen,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Hadith",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            challenge["hadithQuote"] ?? "",
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
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
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Close"),
                    ),
                  ),
                  SizedBox(width: 16),
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
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.grey.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
      backgroundColor: AppColors.menuBackGroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.menuBackGroundColor,
        automaticallyImplyLeading: false,
        title: Text(
          "Challenge Mode",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showChallengeCreationSheet,
            icon: Icon(Icons.add, color: AppColors.primaryDarkGreen, size: 24),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_filled,
                    color: AppColors.primaryGreen,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text("Active"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, color: AppColors.primaryGreen, size: 16),
                  SizedBox(width: 8),
                  Text("Explore"),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history, color: AppColors.primaryGreen, size: 16),
                  SizedBox(width: 8),
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
            icon: Icons.play_circle_outline,
            title: "No Active Challenges",
            subtitle: "Join a challenge to start your spiritual journey",
            actionText: "Explore Challenges",
            onAction: () => _tabController.animateTo(1),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: activeChallenges.length,
            itemBuilder: (context, index) {
              final challenge = activeChallenges[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ActiveChallengeCardWidget(
                  challenge: challenge,
                  onTap: () => _showChallengeDetails(challenge),
                ),
              );
            },
          );
  }

  Widget _buildExploreChallengesTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: availableChallenges.length,
      itemBuilder: (context, index) {
        final challenge = availableChallenges[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ChallengeCardWidget(
            challenge: challenge,
            onTap: () => _showChallengeDetails(challenge),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return challengeHistory.isEmpty
        ? _buildEmptyState(
            icon: Icons.history,
            title: "No Challenge History",
            subtitle: "Complete challenges to see your achievements here",
            actionText: "Start Challenge",
            onAction: () => _tabController.animateTo(1),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: challengeHistory.length,
            itemBuilder: (context, index) {
              final challenge = challengeHistory[index];
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: ChallengeHistoryWidget(challenge: challenge),
              );
            },
          );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String actionText,
    required VoidCallback onAction,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryGreen, size: 64),
            SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            ElevatedButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}
