import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ProgressSummaryWidget extends StatefulWidget {
  final Map<String, dynamic> progressData;
  final VoidCallback onClose;

  const ProgressSummaryWidget({
    super.key,
    required this.progressData,
    required this.onClose,
  });

  @override
  State<ProgressSummaryWidget> createState() => _ProgressSummaryWidgetState();
}

class _ProgressSummaryWidgetState extends State<ProgressSummaryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _closeWithAnimation() {
    _animationController.reverse().then((_) {
      widget.onClose();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _closeWithAnimation,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Container(
            color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
                margin: EdgeInsets.only(top: 15.h, left: 4.w, right: 4.w),
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.lightTheme.colorScheme.shadow,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Progress',
                          style: AppTheme.lightTheme.textTheme.titleLarge
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        IconButton(
                          onPressed: _closeWithAnimation,
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    // Date
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primaryContainer
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.progressData["date"] as String,
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Progress Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: 'radio_button_checked',
                            title: 'Total Count',
                            value: widget.progressData["totalCount"].toString(),
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildStatCard(
                            icon: 'check_circle',
                            title: 'Completed',
                            value:
                                '${widget.progressData["completedPhrases"]}/4',
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 2.h),

                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: 'schedule',
                            title: 'Time Spent',
                            value: widget.progressData["timeSpent"] as String,
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: _buildStatCard(
                            icon: 'local_fire_department',
                            title: 'Streak',
                            value: '${widget.progressData["streak"]} days',
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 3.h),

                    // Maghrib Reset Countdown
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.lightTheme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                color: AppTheme.lightTheme.colorScheme.primary,
                                size: 20,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Auto Reset at Maghrib',
                                style: AppTheme.lightTheme.textTheme.titleMedium
                                    ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            '2:34:15 remaining',
                            style: AppTheme.dhikrCounterStyle(
                              isLight: true,
                            ).copyWith(
                              fontSize: 24.sp,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            'Your progress will be saved and counter will reset',
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 3.h),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              _closeWithAnimation();
                              Navigator.pushNamed(
                                context,
                                '/analytics-dashboard',
                              );
                            },
                            icon: CustomIconWidget(
                              iconName: 'analytics',
                              color: AppTheme.lightTheme.colorScheme.primary,
                              size: 20,
                            ),
                            label: Text('View Analytics'),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _closeWithAnimation();
                              Navigator.pushNamed(context, '/challenge-mode');
                            },
                            icon: CustomIconWidget(
                              iconName: 'emoji_events',
                              color: Colors.white,
                              size: 20,
                            ),
                            label: Text('Challenges'),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 1.h),

                    // Tap to close hint
                    Text(
                      'Tap anywhere to close',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          CustomIconWidget(iconName: icon, color: color, size: 24),
          SizedBox(height: 1.h),
          Text(
            value,
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.5.h),
          Text(
            title,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
