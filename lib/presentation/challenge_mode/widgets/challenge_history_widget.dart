import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChallengeHistoryWidget extends StatelessWidget {
  final Map<String, dynamic> challenge;

  const ChallengeHistoryWidget({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final isGroupChallenge = challenge["type"] == "group";
    final completedDate = DateTime.tryParse(challenge["completedDate"] ?? "");
    final formattedDate = completedDate != null
        ? "${completedDate.day}/${completedDate.month}/${completedDate.year}"
        : "Unknown";

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge["title"] ?? "",
                          style: AppTheme.lightTheme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          "Completed on $formattedDate",
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'emoji_events',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),

              // Achievement badge
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 0.1,
                      ),
                      AppTheme.lightTheme.colorScheme.secondary.withValues(
                        alpha: 0.05,
                      ),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: CustomIconWidget(
                        iconName: 'star',
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge["achievement"] ?? "",
                            style: AppTheme.lightTheme.textTheme.titleSmall
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                          Text(
                            "Achievement Unlocked",
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isGroupChallenge && challenge["rank"] != null) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: _getRankColor(challenge["rank"]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "#${challenge["rank"]}",
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 2.h),

              // Stats row
              Row(
                children: [
                  _buildStatItem(
                    icon: isGroupChallenge ? 'group' : 'person',
                    label: "Type",
                    value: isGroupChallenge ? "Group" : "Solo",
                  ),
                  SizedBox(width: 4.w),
                  _buildStatItem(
                    icon: 'schedule',
                    label: "Duration",
                    value: challenge["duration"] ?? "",
                  ),
                  SizedBox(width: 4.w),
                  _buildStatItem(
                    icon: 'counter_1',
                    label: "Total Dhikr",
                    value: "${challenge["totalDhikr"] ?? 0}",
                  ),
                ],
              ),

              if (isGroupChallenge) ...[
                SizedBox(height: 2.h),
                Row(
                  children: [
                    _buildStatItem(
                      icon: 'people',
                      label: "Participants",
                      value: "${challenge["participants"] ?? 0}",
                    ),
                    SizedBox(width: 4.w),
                    _buildStatItem(
                      icon: 'leaderboard',
                      label: "Final Rank",
                      value: "#${challenge["rank"] ?? 0}",
                    ),
                  ],
                ),
              ],
              SizedBox(height: 2.h),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _showCertificate(context);
                      },
                      icon: CustomIconWidget(
                        iconName: 'file_download',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 16,
                      ),
                      label: Text("Certificate"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _shareAchievement(context);
                      },
                      icon: CustomIconWidget(
                        iconName: 'share',
                        color: Colors.white,
                        size: 16,
                      ),
                      label: Text("Share"),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.primary,
            size: 16,
          ),
          SizedBox(width: 1.w),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int? rank) {
    if (rank == null) return Colors.grey;
    if (rank <= 3) return Colors.amber;
    if (rank <= 10) return Colors.orange;
    return Colors.grey;
  }

  void _showCertificate(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(6.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Certificate header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.lightTheme.colorScheme.primary,
                      AppTheme.lightTheme.colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    CustomIconWidget(
                      iconName: 'emoji_events',
                      color: Colors.white,
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      "Certificate of Completion",
                      style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      challenge["title"] ?? "",
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 3.h),

              // Certificate details
              Text(
                "This certifies that you have successfully completed the challenge with dedication and spiritual commitment.",
                style: AppTheme.lightTheme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),

              Text(
                "Total Dhikr: ${challenge["totalDhikr"]}",
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 1.h),

              Text(
                "Duration: ${challenge["duration"]}",
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 3.h),

              // Action buttons
              Row(
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
                      onPressed: () {
                        Navigator.pop(context);
                        // Handle download certificate
                      },
                      child: Text("Download"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareAchievement(BuildContext context) {
    // Handle sharing achievement
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Achievement shared successfully!"),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }
}
