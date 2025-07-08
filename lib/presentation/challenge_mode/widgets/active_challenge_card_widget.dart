import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ActiveChallengeCardWidget extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final VoidCallback onTap;

  const ActiveChallengeCardWidget({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (challenge["progress"] ?? 0) / (challenge["target"] ?? 1);
    final isGroupChallenge = challenge["type"] == "group";

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.lightTheme.colorScheme.primary.withValues(
                    alpha: 0.1,
                  ),
                  AppTheme.lightTheme.colorScheme.secondary.withValues(
                    alpha: 0.05,
                  ),
                ],
              ),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
                width: 1,
              ),
            ),
            child: Stack(
              children: [
                // Background pattern
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: challenge["backgroundImage"] != null
                          ? DecorationImage(
                              image: NetworkImage(
                                challenge["backgroundImage"],
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.white.withValues(alpha: 0.9),
                                BlendMode.overlay,
                              ),
                            )
                          : null,
                    ),
                  ),
                ),
                // Content
                Padding(
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
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color:
                                        AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  challenge["description"] ?? "",
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: isGroupChallenge
                                  ? AppTheme.lightTheme.colorScheme.secondary
                                  : AppTheme.lightTheme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName:
                                      isGroupChallenge ? 'group' : 'person',
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 1.w),
                                Text(
                                  isGroupChallenge ? "Group" : "Solo",
                                  style: AppTheme
                                      .lightTheme.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Progress section
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Progress",
                                      style: AppTheme
                                          .lightTheme.textTheme.labelMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "${(progress * 100).toInt()}%",
                                      style: AppTheme
                                          .lightTheme.textTheme.labelMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme
                                            .lightTheme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 1.h),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: AppTheme
                                      .lightTheme.colorScheme.primary
                                      .withValues(alpha: 0.2),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.lightTheme.colorScheme.primary,
                                  ),
                                  minHeight: 6,
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  "${challenge["progress"]} / ${challenge["target"]} completed",
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Stats row
                      Row(
                        children: [
                          _buildStatItem(
                            icon: 'calendar_today',
                            label: "Day",
                            value:
                                "${challenge["currentDay"]}/${challenge["totalDays"]}",
                          ),
                          SizedBox(width: 4.w),
                          _buildStatItem(
                            icon: 'schedule',
                            label: "Time Left",
                            value: challenge["timeRemaining"] ?? "",
                          ),
                          if (isGroupChallenge) ...[
                            SizedBox(width: 4.w),
                            _buildStatItem(
                              icon: 'group',
                              label: "Participants",
                              value: "${challenge["participants"]}",
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Navigate to main counter with challenge context
                                Navigator.pushNamed(
                                  context,
                                  '/main-dhikr-counter',
                                );
                              },
                              icon: CustomIconWidget(
                                iconName: 'play_arrow',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 16,
                              ),
                              label: Text("Continue"),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onTap,
                              icon: CustomIconWidget(
                                iconName: 'info',
                                color: Colors.white,
                                size: 16,
                              ),
                              label: Text("Details"),
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
              ],
            ),
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
}
