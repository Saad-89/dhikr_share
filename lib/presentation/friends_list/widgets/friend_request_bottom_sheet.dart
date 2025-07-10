import 'package:dhikr_share/domain/models/user_model.dart';
import 'package:dhikr_share/viewmodels/friend_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FriendRequestBottomSheet extends StatelessWidget {
  final List<Map<String, dynamic>> friendRequests;
  final Function(Map<String, dynamic>) onAcceptRequest;
  final Function(Map<String, dynamic>) onDeclineRequest;

  const FriendRequestBottomSheet({
    super.key,
    required this.friendRequests,
    required this.onAcceptRequest,
    required this.onDeclineRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 3.h),
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Friend Requests',
                  style: AppTheme.lightTheme.textTheme.titleLarge,
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${friendRequests.length}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          // Friend requests list
          Expanded(
            child:
                friendRequests.isEmpty
                    ? _buildEmptyState()
                    : Consumer<FriendViewmodel>(
                      builder: (context, friendProvider, child) {
                        if (friendProvider.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final friendRequests = friendProvider.requestSenders;

                        if (friendRequests.isEmpty) {
                          return _buildEmptyState();
                        }

                        return ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          itemCount: friendRequests.length,
                          itemBuilder: (context, index) {
                            final request = friendRequests[index];
                            return _buildRequestCard(context, request);
                          },
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'person_add_disabled',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            'No Friend Requests',
            style: AppTheme.lightTheme.textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          Text(
            'When someone sends you a friend request,\nit will appear here',
            style: AppTheme.lightTheme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, UserModel user) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            Row(
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 8.w,
                  // backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
                  //     ? NetworkImage(user.profileImage!)
                  //     : null,
                  child: Icon(Icons.person, size: 8.w),
                ),
                SizedBox(width: 4.w),
                // User Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.username,
                        style: AppTheme.lightTheme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        user.email,
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color:
                                  AppTheme
                                      .lightTheme
                                      .colorScheme
                                      .onSurfaceVariant,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'people',
                            color:
                                AppTheme
                                    .lightTheme
                                    .colorScheme
                                    .onSurfaceVariant,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '0 mutual friends', // Optional: replace with real logic later
                            style: AppTheme.lightTheme.textTheme.bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme
                                          .lightTheme
                                          .colorScheme
                                          .onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Time
                Text(
                  timeAgo(
                    user.requestTimestamp?.toDate() ?? DateTime.now(),
                  ), // Optional: Use real timestamp if you store it
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onDeclineRequest,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                      foregroundColor: AppTheme.lightTheme.colorScheme.error,
                    ),
                    child: const Text('Decline'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onAcceptRequest,
                    child: const Text('Accept'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24)
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  if (difference.inDays < 7)
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
