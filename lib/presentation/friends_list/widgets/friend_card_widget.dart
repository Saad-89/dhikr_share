import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FriendCardWidget extends StatelessWidget {
  final Map<String, dynamic> friend;
  final Function(String) onSendEncouragement;
  final VoidCallback onRemoveFriend;
  final VoidCallback onViewProfile;

  const FriendCardWidget({
    super.key,
    required this.friend,
    required this.onSendEncouragement,
    required this.onRemoveFriend,
    required this.onViewProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('friend_${friend['id']}'),
      background: _buildSwipeBackground(context, isLeft: false),
      secondaryBackground: _buildSwipeBackground(context, isLeft: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _showFriendOptions(context);
        } else {
          _showEncouragementOptions(context);
        }
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 2.h),
        child: InkWell(
          onTap: onViewProfile,
          onLongPress: () => onViewProfile(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Profile Picture with Online Status
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 8.w,
                      backgroundImage: NetworkImage(friend['profileImage']),
                    ),
                    if (friend['isOnline'] == true)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(width: 4.w),
                // Friend Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend['name'],
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        friend['username'],
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        'Last active: ${friend['lastActive']}',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Dhikr Progress
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildDhikrDisplay(),
                    SizedBox(height: 1.h),
                    _buildProgressIndicator(),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDhikrDisplay() {
    final privacyLevel = friend['privacyLevel'] as String;
    final todayDhikr = friend['todayDhikr'] as int;

    if (privacyLevel == 'private') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'lock',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 12,
            ),
            SizedBox(width: 1.w),
            Text(
              'Private',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$todayDhikr',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Today\'s Dhikr',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final privacyLevel = friend['privacyLevel'] as String;
    final todayDhikr = friend['todayDhikr'] as int;

    if (privacyLevel == 'private') {
      return const SizedBox.shrink();
    }

    final progress = (todayDhikr / 300).clamp(0.0, 1.0);

    return Container(
      width: 20.w,
      height: 0.5.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress,
        child: Container(
          decoration: BoxDecoration(
            color: _getProgressColor(progress),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else if (progress >= 0.5) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else {
      return AppTheme.lightTheme.colorScheme.secondary;
    }
  }

  Widget _buildSwipeBackground(BuildContext context, {required bool isLeft}) {
    if (isLeft) {
      // Right swipe - Remove friend
      return Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 4.w),
        color: AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'person_remove',
              color: AppTheme.lightTheme.colorScheme.error,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Remove',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.error,
              ),
            ),
          ],
        ),
      );
    } else {
      // Left swipe - Send encouragement
      return Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'favorite',
              color: AppTheme.lightTheme.colorScheme.tertiary,
              size: 24,
            ),
            SizedBox(height: 0.5.h),
            Text(
              'Encourage',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.tertiary,
              ),
            ),
          ],
        ),
      );
    }
  }

  void _showEncouragementOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Send Encouragement to ${friend['name']}',
              style: AppTheme.lightTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEncouragementOption(
                  context,
                  'Send Dua',
                  'mosque',
                  'dua',
                ),
                _buildEncouragementOption(
                  context,
                  'Thumbs Up',
                  'thumb_up',
                  'thumbs_up',
                ),
                _buildEncouragementOption(
                  context,
                  'Motivate',
                  'auto_awesome',
                  'motivational',
                ),
              ],
            ),
            SizedBox(height: 3.h),
          ],
        ),
      ),
    );
  }

  Widget _buildEncouragementOption(
    BuildContext context,
    String label,
    String iconName,
    String type,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onSendEncouragement(type);
      },
      child: Column(
        children: [
          Container(
            width: 15.w,
            height: 15.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primary.withValues(
                alpha: 0.1,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showFriendOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              'Friend Options',
              style: AppTheme.lightTheme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'notifications_off',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Mute Updates'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Muted updates from ${friend['name']}'),
                  ),
                );
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.lightTheme.colorScheme.onSurface,
                size: 24,
              ),
              title: const Text('Notification Preferences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            ListTile(
              leading: CustomIconWidget(
                iconName: 'person_remove',
                color: AppTheme.lightTheme.colorScheme.error,
                size: 24,
              ),
              title: Text(
                'Remove Friend',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                onRemoveFriend();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }
}
