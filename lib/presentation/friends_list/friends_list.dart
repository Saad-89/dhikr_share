import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dhikr_share/viewmodels/friend_viewmodel.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_friends_state_widget.dart';
import './widgets/friend_card_widget.dart';
import './widgets/friend_request_bottom_sheet.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key});

  @override
  State<FriendsList> createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _searchQuery = '';
  String? _processingRequestId;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  // Real-time stream for friends
  Stream<List<Map<String, dynamic>>> get _friendsStream {
    return _firestore
        .collection('Users')
        .doc(_currentUserId)
        .collection('friends')
        .snapshots()
        .asyncMap((snapshot) async {
      final friends = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final friendData = doc.data();
        final friend = {
          'id': doc.id,
          'friendId': friendData['friendId'],
          'name': friendData['friendName'],
          'username': friendData['username'] ??
              '@${friendData['friendName'].toLowerCase().replaceAll(' ', '_')}',
          'profileImage': friendData['profileImage'] ?? '',
          'lastActive': friendData['lastActive'] ?? 'Unknown',
          'addedAt': friendData['addedAt'],
          'isOnline': _isUserOnline(friendData['lastActive']),
          'todayDhikr': await _getTodayDhikrCount(friendData['friendId']),
          'privacyLevel': friendData['privacyLevel'] ?? 'public',
          'weeklyProgress': await _getWeeklyProgress(friendData['friendId']),
          'achievements': await _getAchievements(friendData['friendId']),
        };
        friends.add(friend);
      }

      return friends;
    });
  }

  // Real-time stream for friend requests
  Stream<List<Map<String, dynamic>>> get _friendRequestsStream {
    return _firestore
        .collection('friend_requests')
        .where('to', isEqualTo: _currentUserId)
        .snapshots()
        .asyncMap((snapshot) async {
      final requests = <Map<String, dynamic>>[];

      for (final doc in snapshot.docs) {
        final requestData = doc.data();
        final senderId = requestData['from'];

        // Fetch sender's profile from Firestore
        final senderDoc = await _firestore
            .collection('Users')
            .doc(senderId)
            .get();

        if (!senderDoc.exists) {
          continue;
        }

        final senderData = senderDoc.data()!;
        final mutualFriends = await _getMutualFriendsCount(senderId);

        requests.add({
          'id': doc.id,
          'senderId': senderId,
          'name': senderData['username'],
          'email': senderData['email'],
          'profileImage': senderData['profileImage'] ?? '',
          'requestTime': requestData['timestamp'],
          'mutualFriends': mutualFriends,
        });
      }

      return requests;
    });
  }

  // Real-time stream for discover users
  Stream<List<Map<String, dynamic>>> get _discoverUsersStream {
    return _firestore
        .collection('Users')
        .snapshots()
        .asyncMap((allUsersSnapshot) async {
      final allUserIds = allUsersSnapshot.docs.map((doc) => doc.id).toList();
      
      // Remove current user from the list
      allUserIds.remove(_currentUserId);

      // Get current user's friends
      final friendsSnapshot = await _firestore
          .collection('Users')
          .doc(_currentUserId)
          .collection('friends')
          .get();

      final friendIds = friendsSnapshot.docs.map((doc) => doc.id).toSet();
      
      // Remove friend UIDs from the list
      allUserIds.removeWhere((id) => friendIds.contains(id));

      final List<Map<String, dynamic>> discover = [];

      for (final userId in allUserIds) {
        final userDoc = await _firestore.collection('Users').doc(userId).get();

        if (!userDoc.exists) {
          continue;
        }

        final userData = userDoc.data();
        if (userData == null) {
          continue;
        }

        discover.add({
          'id': userId,
          'name': userData['username'] ?? 'Unknown',
          'username': '@${(userData['username'] ?? 'unknown').toLowerCase().replaceAll(' ', '_')}',
          'profileImage': userData['profileImage'] ?? '',
          'location': userData['location'] ?? 'Unknown',
          'mutualFriends': await _getMutualFriendsCount(userId),
        });
      }

      return discover;
    });
  }

  bool _isUserOnline(dynamic lastActive) {
    if (lastActive == null) return false;

    DateTime lastActiveDate;
    if (lastActive is Timestamp) {
      lastActiveDate = lastActive.toDate();
    } else if (lastActive is String) {
      try {
        lastActiveDate = DateTime.parse(lastActive);
      } catch (e) {
        return false;
      }
    } else {
      return false;
    }

    final now = DateTime.now();
    final difference = now.difference(lastActiveDate);
    return difference.inMinutes < 15;
  }

  Future<int> _getTodayDhikrCount(String userId) async {
    try {
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final dhikrDoc = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('daily_dhikr')
          .doc(todayString)
          .get();

      if (dhikrDoc.exists) {
        return dhikrDoc.data()?['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  Future<List<int>> _getWeeklyProgress(String userId) async {
    try {
      final now = DateTime.now();
      final weeklyProgress = <int>[];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateString =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

        final dhikrDoc = await _firestore
            .collection('Users')
            .doc(userId)
            .collection('daily_dhikr')
            .doc(dateString)
            .get();

        weeklyProgress.add(
          dhikrDoc.exists ? (dhikrDoc.data()?['count'] ?? 0) : 0,
        );
      }

      return weeklyProgress;
    } catch (e) {
      return List.filled(7, 0);
    }
  }

  Future<List<String>> _getAchievements(String userId) async {
    return ['Daily Practitioner']; // Placeholder
  }

  Future<int> _getMutualFriendsCount(String userId) async {
    try {
      final currentUserFriends = await _firestore
          .collection('Users')
          .doc(_currentUserId)
          .collection('friends')
          .get();

      final otherUserFriends = await _firestore
          .collection('Users')
          .doc(userId)
          .collection('friends')
          .get();

      final currentFriendIds =
          currentUserFriends.docs.map((doc) => doc.data()['friendId']).toSet();
      final otherFriendIds =
          otherUserFriends.docs.map((doc) => doc.data()['friendId']).toSet();

      return currentFriendIds.intersection(otherFriendIds).length;
    } catch (e) {
      return 0;
    }
  }

  List<Map<String, dynamic>> _getFilteredFriends(List<Map<String, dynamic>> friends) {
    if (_searchQuery.isEmpty) return friends;
    return friends.where((friend) {
      final name = (friend['name'] as String).toLowerCase();
      final username = (friend['username'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();
  }

  // Updated _showFriendRequests method with StreamBuilder
  void _showFriendRequests() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StreamBuilder<List<Map<String, dynamic>>>(
        stream: _friendRequestsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
              height: 50.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Center(child: CircularProgressIndicator(color: AppTheme.primaryDark,)),
            );
          }

          final friendRequests = snapshot.data ?? [];

          return FriendRequestBottomSheet(
            friendRequests: friendRequests,
            onAcceptRequest: _acceptFriendRequest,
            onDeclineRequest: _declineFriendRequest,
            processingRequestId: _processingRequestId,
          );
        },
      ),
    );
  }

  // Updated _acceptFriendRequest function
  Future<void> _acceptFriendRequest(Map<String, dynamic> request) async {
    try {
      final requestId = request['id']?.toString();
      if (requestId == null) {
        throw Exception('Invalid friend request data');
      }

      setState(() {
        _processingRequestId = requestId;
      });

      final batch = _firestore.batch();
      final currentUserDoc =
          await _firestore.collection('Users').doc(_currentUserId).get();
      final otherUserDoc =
          await _firestore.collection('Users').doc(request['senderId']).get();

      if (currentUserDoc.exists && otherUserDoc.exists) {
        final currentUserData = currentUserDoc.data()!;
        final otherUserData = otherUserDoc.data()!;

        // Add friend to current user's friends subcollection
        batch.set(
          _firestore
              .collection('Users')
              .doc(_currentUserId)
              .collection('friends')
              .doc(request['senderId']),
          {
            'friendId': request['senderId'],
            'friendName': otherUserData['username'],
            'profileImage': otherUserData['profileImage'] ?? '',
            'lastActive': otherUserData['lastActive'],
            'addedAt': FieldValue.serverTimestamp(),
            'username': otherUserData['username'],
            'privacyLevel': otherUserData['privacyLevel'] ?? 'public',
          },
        );

        // Add friend to other user's friends subcollection
        batch.set(
          _firestore
              .collection('Users')
              .doc(request['senderId'])
              .collection('friends')
              .doc(_currentUserId),
          {
            'friendId': _currentUserId,
            'friendName': currentUserData['username'],
            'profileImage': currentUserData['profileImage'] ?? '',
            'lastActive': currentUserData['lastActive'],
            'addedAt': FieldValue.serverTimestamp(),
            'username': currentUserData['username'],
            'privacyLevel': currentUserData['privacyLevel'] ?? 'public',
          },
        );

        // Delete the friend request
        batch.delete(
          _firestore.collection('friend_requests').doc(requestId),
        );

        await batch.commit();

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend request accepted!')),
          );
        }
      }
    } catch (e) {
      print('Error accepting friend request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to accept friend request')),
        );
      }
    } finally {
      setState(() {
        _processingRequestId = null;
      });
    }
  }

  // Updated _declineFriendRequest function
  Future<void> _declineFriendRequest(Map<String, dynamic> request) async {
    try {
      final requestId = request['id']?.toString();
      if (requestId == null) {
        throw Exception('Invalid friend request data');
      }

      setState(() {
        _processingRequestId = requestId;
      });

      // Delete the friend request from Firestore
      await _firestore.collection('friend_requests').doc(requestId).delete();

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request declined')),
        );
      }
    } catch (e) {
      print('Error declining friend request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to decline friend request')),
        );
      }
    } finally {
      setState(() {
        _processingRequestId = null;
      });
    }
  }

  void _showAddFriendDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Add Friend',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Enter Email',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Invite friends to join your spiritual journey',
              style: AppTheme.lightTheme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Consumer<FriendViewmodel>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const CircularProgressIndicator(color: AppTheme.primaryDark);
              }
              return ElevatedButton(
                onPressed: () {
                  provider.sendFriendRequestByEmail(
                    context,
                    emailController.text ?? "",
                  );
                },
                child: const Text('Send Request'),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _sendEncouragement(
    Map<String, dynamic> friend,
    String type,
  ) async {
    try {
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Check if already sent encouragement today
      final existingEncouragement = await _firestore
          .collection('Users')
          .doc(friend['friendId'])
          .collection('encouragements')
          .doc(_currentUserId)
          .collection('daily')
          .doc(todayString)
          .get();

      if (existingEncouragement.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You already sent encouragement today')),
        );
        return;
      }

      // Send encouragement
      await _firestore
          .collection('Users')
          .doc(friend['friendId'])
          .collection('encouragements')
          .doc(_currentUserId)
          .collection('daily')
          .doc(todayString)
          .set({'type': type, 'timestamp': FieldValue.serverTimestamp()});

      String message = '';
      switch (type) {
        case 'dua':
          message = 'Sent a Dua to ${friend['name']}';
          break;
        case 'thumbs_up':
          message = 'Sent encouragement to ${friend['name']}';
          break;
        case 'motivational':
          message = 'Sent motivational message to ${friend['name']}';
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      print('Error sending encouragement: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send encouragement')),
      );
    }
  }

  Future<void> _removeFriend(Map<String, dynamic> friend) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
          'Are you sure you want to remove ${friend['name']} from your friends list?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                Navigator.pop(context);

                final batch = _firestore.batch();

                // Remove from current user's friends
                batch.delete(
                  _firestore
                      .collection('Users')
                      .doc(_currentUserId)
                      .collection('friends')
                      .doc(friend['friendId']),
                );

                // Remove from other user's friends
                batch.delete(
                  _firestore
                      .collection('Users')
                      .doc(friend['friendId'])
                      .collection('friends')
                      .doc(_currentUserId),
                );

                await batch.commit();

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${friend['name']} removed from friends'),
                    ),
                  );
                }
              } catch (e) {
                print('Error removing friend: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to remove friend')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendDiscoverFriendRequest(Map<String, dynamic> user) async {
    try {
      // Check if request already exists
      final existingRequest = await _firestore
          .collection('friend_requests')
          .where('from', isEqualTo: _currentUserId)
          .where('to', isEqualTo: user['id'])
          .limit(1)
          .get();

      if (existingRequest.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Friend request already sent')),
        );
        return;
      }

      // Send friend request
      await _firestore.collection('friend_requests').add({
        'from': _currentUserId,
        'to': user['id'],
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Friend request sent to ${user['name']}')),
      );
    } catch (e) {
      print('Error sending friend request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send friend request')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Friends',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        actions: [
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: _friendRequestsStream,
            builder: (context, snapshot) {
              final friendRequests = snapshot.data ?? [];
              return Stack(
                children: [
                  IconButton(
                    onPressed: _showFriendRequests,
                    icon: CustomIconWidget(
                      iconName: 'person_add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  if (friendRequests.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 2,
                      child: Container(
                        height: 20,
                        width: 20,
                        padding: EdgeInsets.all(0.5.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(minWidth: 4.w, minHeight: 4.w),
                        child: Text(
                          '${friendRequests.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10.h),
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search friends...',
                    prefixIcon: CustomIconWidget(
                      iconName: 'search',
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                ),
              ),
              // Tab Bar
              TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Friends'), Tab(text: 'Discover')],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFriendsTab(), _buildDiscoverTab()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
        child: CustomIconWidget(
          iconName: 'person_add',
          color: AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor!,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _friendsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryDark));
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Error loading friends',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Please try again later',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                ),
              ],
            ),
          );
        }

        final friends = snapshot.data ?? [];
        final filteredFriends = _getFilteredFriends(friends);

        if (filteredFriends.isEmpty && _searchQuery.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'search_off',
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'No friends found',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  'Try searching with a different name or username',
                  style: AppTheme.lightTheme.textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (friends.isEmpty) {
          return EmptyFriendsStateWidget(onInviteFriends: _showAddFriendDialog);
        }

        return ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          itemCount: filteredFriends.length,
          itemBuilder: (context, index) {
            final friend = filteredFriends[index];
            return FriendCardWidget(
              friend: friend,
              onSendEncouragement: (type) => _sendEncouragement(friend, type),
              onRemoveFriend: () => _removeFriend(friend),
              onViewProfile: () {
                Navigator.pushNamed(context, '/analytics-dashboard');
              },
            );
          },
        );
      },
    );
  }

  Widget _buildDiscoverTab() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _discoverUsersStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  color: AppTheme.lightTheme.colorScheme.error,
                  size: 48,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Error loading users',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
          );
        }

        final discoverUsers = snapshot.data ?? [];

        if (discoverUsers.isEmpty) {
          return const Center(child: Text('No users to discover'));
        }

        return ListView(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          children: [
            Text(
              'Suggested Friends',
              style: AppTheme.lightTheme.textTheme.titleMedium,
            ),
            SizedBox(height: 2.h),
            ...discoverUsers.map(
              (suggestion) => Card(
                margin: EdgeInsets.only(bottom: 2.h),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 6.w,
                    backgroundImage: suggestion['profileImage'].isNotEmpty
                        ? NetworkImage(suggestion['profileImage'])
                        : null,
                    child: suggestion['profileImage'].isEmpty
                        ? Icon(Icons.person, size: 6.w)
                        : null,
                  ),
                  title: Text(
                    suggestion['name'],
                    style: AppTheme.lightTheme.textTheme.titleSmall,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion['username'],
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      Text(
                       '${suggestion['mutualFriends']} mutual friends • ${suggestion['location']}',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _sendDiscoverFriendRequest(suggestion),
                style: ElevatedButton.styleFrom(minimumSize: Size(20.w, 5.h)),
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      ],
    );
      });}
}

String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) {
    return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  }
  if (difference.inDays < 7) {
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  }
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}







// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:dhikr_share/viewmodels/friend_viewmodel.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:sizer/sizer.dart';

// import '../../core/app_export.dart';
// import './widgets/empty_friends_state_widget.dart';
// import './widgets/friend_card_widget.dart';
// import './widgets/friend_request_bottom_sheet.dart';

// class FriendsList extends StatefulWidget {
//   const FriendsList({super.key});

//   @override
//   State<FriendsList> createState() => _FriendsListState();
// }

// class _FriendsListState extends State<FriendsList>
//     with TickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   bool _isLoading = false;
//   String _searchQuery = '';

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   List<Map<String, dynamic>> _friendsList = [];
//   List<Map<String, dynamic>> _friendRequests = [];
//   List<Map<String, dynamic>> _discoverUsers = [];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }

//   String get _currentUserId => _auth.currentUser?.uid ?? '';

//   Future<void> _loadData() async {
//     setState(() => _isLoading = true);

//     await Future.wait([
//       _loadFriends(),
//       _loadFriendRequests(),
//       _loadDiscoverUsers(),
//     ]);

//     setState(() => _isLoading = false);
//   }

//   Future<void> _loadFriends() async {
//     try {
//       final friendsSnapshot =
//           await _firestore
//               .collection('Users')
//               .doc(_currentUserId)
//               .collection('friends')
//               .get();

//       final friends = <Map<String, dynamic>>[];

//       for (final doc in friendsSnapshot.docs) {
//         final friendData = doc.data();
//         friends.add({
//           'id': doc.id,
//           'friendId': friendData['friendId'],
//           'name': friendData['friendName'],
//           'username':
//               friendData['username'] ??
//               '@${friendData['friendName'].toLowerCase().replaceAll(' ', '_')}',
//           'profileImage': friendData['profileImage'] ?? '',
//           'lastActive': friendData['lastActive'] ?? 'Unknown',
//           'addedAt': friendData['addedAt'],
//           'isOnline': _isUserOnline(friendData['lastActive']),
//           'todayDhikr': await _getTodayDhikrCount(friendData['friendId']),
//           'privacyLevel': friendData['privacyLevel'] ?? 'public',
//           'weeklyProgress': await _getWeeklyProgress(friendData['friendId']),
//           'achievements': await _getAchievements(friendData['friendId']),
//         });
//       }

//       setState(() {
//         _friendsList = friends;
//       });
//     } catch (e) {
//       print('Error loading friends: $e');
//     }
//   }

//   Future<void> _loadFriendRequests() async {
//     try {
//       // 1. Fetch all incoming friend requests for current user
//       final requestsSnapshot =
//           await _firestore
//               .collection('friend_requests')
//               .where('to', isEqualTo: _currentUserId)
//               .get();

//       // debugPrint('✅ Total Friend Requests: ${requestsSnapshot.docs.length}');

//       final requests = <Map<String, dynamic>>[];

//       for (final doc in requestsSnapshot.docs) {
//         final requestData = doc.data();
//         final senderId = requestData['from'];

//         // debugPrint('🔄 Processing request from senderId: $senderId');

//         // 2. Fetch sender's profile from Firestore (Users collection)
//         final senderDoc =
//             await _firestore
//                 .collection(
//                   'Users',
//                 ) // ✅ Make sure collection is lowercase 'Users'
//                 .doc(senderId)
//                 .get();

//         if (!senderDoc.exists) {
//           // debugPrint('⚠️ Sender document not found for UID: $senderId');
//           continue;
//         }

//         final senderData = senderDoc.data()!;
//         // debugPrint('📥 Loaded sender data for: ${senderData['username']}');

//         final mutualFriends = await _getMutualFriendsCount(senderId);
//         // debugPrint('👥 Mutual friends with $senderId: $mutualFriends');

//         requests.add({
//           'id': doc.id,
//           'senderId': senderId,
//           'name': senderData['username'],
//           'email': senderData['email'],
//           'profileImage': senderData['profileImage'] ?? '',
//           'requestTime': requestData['timestamp'],
//           'mutualFriends': mutualFriends,
//         });
//       }

//       // debugPrint('✅ Total Processed Friend Requests: ${requests.length}');

//       setState(() {
//         _friendRequests = requests;
//       });
//     } catch (e) {
//       print('❌ Error loading friend requests: $e');
//     }
//   }

//   Future<void> _loadDiscoverUsers() async {
//     try {
//       // 1. Fetch all Users and extract their UIDs
//       final allUsersSnapshot = await _firestore.collection('Users').get();
//       final allUserIds = allUsersSnapshot.docs.map((doc) => doc.id).toList();
//       // debugPrint('✅ Total Users: ${allUserIds.length}');
//       // debugPrint('🔹 All User IDs: $allUserIds');

//       // 2. Remove current user from the list
//       allUserIds.remove(_currentUserId);

//       // 3. Fetch current user's friends
//       final friendsSnapshot =
//           await _firestore
//               .collection('Users')
//               .doc(_currentUserId)
//               .collection('friends')
//               .get();

//       final friendIds = friendsSnapshot.docs.map((doc) => doc.id).toSet();
//       // debugPrint('✅ Total Friends: ${friendIds.length}');
//       // debugPrint('🔸 Friend IDs: $friendIds');

//       // 4. Remove friend UIDs from the list
//       allUserIds.removeWhere((id) => friendIds.contains(id));
//       // debugPrint('✅ Final Discoverable User IDs (excluding current user & friends): $allUserIds');

//       // 5. Fetch user data for remaining discoverable Users
//       final List<Map<String, dynamic>> discover = [];

//       for (final userId in allUserIds) {
//         final userDoc = await _firestore.collection('Users').doc(userId).get();

//         if (!userDoc.exists) {
//           // debugPrint('⚠️ Skipped $userId — Document does not exist');
//           continue;
//         }

//         final userData = userDoc.data();
//         if (userData == null) {
//           // debugPrint('⚠️ Skipped $userId — userData is null');
//           continue;
//         }

//         // debugPrint('📥 Including user $userId in discover list');

//         discover.add({
//           'id': userId,
//           'name': userData['username'] ?? 'Unknown',
//           'username':
//               '@${(userData['username'] ?? 'unknown').toLowerCase().replaceAll(' ', '_')}',
//           'profileImage': userData['profileImage'] ?? '',
//           'location': userData['location'] ?? 'Unknown',
//           'mutualFriends': await _getMutualFriendsCount(userId),
//         });
//       }

//       // debugPrint('✅ Total Discoverable Users Loaded: ${discover.length}');

//       setState(() {
//         _discoverUsers = discover;
//       });
//     } catch (e) {
//       print('❌ Error loading discover Users: $e');
//     }
//   }

//   bool _isUserOnline(dynamic lastActive) {
//     if (lastActive == null) return false;

//     DateTime lastActiveDate;
//     if (lastActive is Timestamp) {
//       lastActiveDate = lastActive.toDate();
//     } else if (lastActive is String) {
//       try {
//         lastActiveDate = DateTime.parse(lastActive);
//       } catch (e) {
//         return false;
//       }
//     } else {
//       return false;
//     }

//     final now = DateTime.now();
//     final difference = now.difference(lastActiveDate);
//     return difference.inMinutes <
//         15; // Consider online if active within 15 minutes
//   }

//   Future<int> _getTodayDhikrCount(String userId) async {
//     try {
//       final today = DateTime.now();
//       final todayString =
//           '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

//       final dhikrDoc =
//           await _firestore
//               .collection('Users')
//               .doc(userId)
//               .collection('daily_dhikr')
//               .doc(todayString)
//               .get();

//       if (dhikrDoc.exists) {
//         return dhikrDoc.data()?['count'] ?? 0;
//       }
//       return 0;
//     } catch (e) {
//       return 0;
//     }
//   }

//   Future<List<int>> _getWeeklyProgress(String userId) async {
//     try {
//       final now = DateTime.now();
//       final weeklyProgress = <int>[];

//       for (int i = 6; i >= 0; i--) {
//         final date = now.subtract(Duration(days: i));
//         final dateString =
//             '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

//         final dhikrDoc =
//             await _firestore
//                 .collection('Users')
//                 .doc(userId)
//                 .collection('daily_dhikr')
//                 .doc(dateString)
//                 .get();

//         weeklyProgress.add(
//           dhikrDoc.exists ? (dhikrDoc.data()?['count'] ?? 0) : 0,
//         );
//       }

//       return weeklyProgress;
//     } catch (e) {
//       return List.filled(7, 0);
//     }
//   }

//   Future<List<String>> _getAchievements(String userId) async {
//     // Implement achievement logic based on your app's requirements
//     return ['Daily Practitioner']; // Placeholder
//   }

//   Future<int> _getMutualFriendsCount(String userId) async {
//     try {
//       final currentUserFriends =
//           await _firestore
//               .collection('Users')
//               .doc(_currentUserId)
//               .collection('friends')
//               .get();

//       final otherUserFriends =
//           await _firestore
//               .collection('Users')
//               .doc(userId)
//               .collection('friends')
//               .get();

//       final currentFriendIds =
//           currentUserFriends.docs.map((doc) => doc.data()['friendId']).toSet();
//       final otherFriendIds =
//           otherUserFriends.docs.map((doc) => doc.data()['friendId']).toSet();

//       return currentFriendIds.intersection(otherFriendIds).length;
//     } catch (e) {
//       return 0;
//     }
//   }

//   List<Map<String, dynamic>> get _filteredFriends {
//     if (_searchQuery.isEmpty) return _friendsList;
//     return _friendsList.where((friend) {
//       final name = (friend['name'] as String).toLowerCase();
//       final username = (friend['username'] as String).toLowerCase();
//       final query = _searchQuery.toLowerCase();
//       return name.contains(query) || username.contains(query);
//     }).toList();
//   }

//   Future<void> _refreshFriends() async {
//     await _loadData();
//   }


// // Updated _showFriendRequests method
// void _showFriendRequests() {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     backgroundColor: Colors.transparent,
//     builder: (context) => FriendRequestBottomSheet(
//       friendRequests: _friendRequests,
//       onAcceptRequest: _acceptFriendRequest,
//       onDeclineRequest: _declineFriendRequest,
//       processingRequestId: _processingRequestId,
//     ),
//   );
// }

// // Add this variable to your _FriendsListState class
// String? _processingRequestId;

// // Updated _acceptFriendRequest function
// Future<void> _acceptFriendRequest(Map<String, dynamic> request) async {
//   try {
//     // Use the actual request ID for processing state
//     final requestId = request['id']?.toString();
//     if (requestId == null) {
//       throw Exception('Invalid friend request data');
//     }

//     setState(() {
//       _processingRequestId = requestId;
//     });

//     final batch = _firestore.batch();
//     final currentUserDoc =
//         await _firestore.collection('Users').doc(_currentUserId).get();
//     final otherUserDoc =
//         await _firestore.collection('Users').doc(request['senderId']).get();

//     if (currentUserDoc.exists && otherUserDoc.exists) {
//       final currentUserData = currentUserDoc.data()!;
//       final otherUserData = otherUserDoc.data()!;

//       // Add friend to current user's friends subcollection
//       batch.set(
//         _firestore
//             .collection('Users')
//             .doc(_currentUserId)
//             .collection('friends')
//             .doc(request['senderId']),
//         {
//           'friendId': request['senderId'],
//           'friendName': otherUserData['username'],
//           'profileImage': otherUserData['profileImage'] ?? '',
//           'lastActive': otherUserData['lastActive'],
//           'addedAt': FieldValue.serverTimestamp(),
//           'username': otherUserData['username'],
//           'privacyLevel': otherUserData['privacyLevel'] ?? 'public',
//         },
//       );

//       // Add friend to other user's friends subcollection
//       batch.set(
//         _firestore
//             .collection('Users')
//             .doc(request['senderId'])
//             .collection('friends')
//             .doc(_currentUserId),
//         {
//           'friendId': _currentUserId,
//           'friendName': currentUserData['username'],
//           'profileImage': currentUserData['profileImage'] ?? '',
//           'lastActive': currentUserData['lastActive'],
//           'addedAt': FieldValue.serverTimestamp(),
//           'username': currentUserData['username'],
//           'privacyLevel': currentUserData['privacyLevel'] ?? 'public',
//         },
//       );

//       // Delete the friend request
//       batch.delete(
//         _firestore.collection('friend_requests').doc(requestId),
//       );

//       await batch.commit();

//       // Remove from local state immediately for UI update
//       setState(() {
//         _friendRequests.removeWhere((req) => req['id'] == requestId);
//       });

//       // Refresh friends list to show new friend
//       await _loadFriends();

//       if (mounted) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Friend request accepted!')),
//         );
//       }
//     }
//   } catch (e) {
//     print('Error accepting friend request: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to accept friend request')),
//       );
//     }
//   } finally {
//     setState(() {
//       _processingRequestId = null;
//     });
//   }
// }

// // Updated _declineFriendRequest function
// Future<void> _declineFriendRequest(Map<String, dynamic> request) async {
//   try {
//     final requestId = request['id']?.toString();
//     if (requestId == null) {
//       throw Exception('Invalid friend request data');
//     }

//     setState(() {
//       _processingRequestId = requestId;
//     });

//     // Delete the friend request from Firestore
//     await _firestore.collection('friend_requests').doc(requestId).delete();

//     // Remove from local state immediately for UI update
//     setState(() {
//       _friendRequests.removeWhere((req) => req['id'] == requestId);
//     });

//     if (mounted) {
//       Navigator.pop(context);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Friend request declined')),
//       );
//     }
//   } catch (e) {
//     print('Error declining friend request: $e');
//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to decline friend request')),
//       );
//     }
//   } finally {
//     setState(() {
//       _processingRequestId = null;
//     });
//   }
// }
  

//   void _showAddFriendDialog() {
//     final emailController = TextEditingController();
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: Text(
//               'Add Friend',
//               style: AppTheme.lightTheme.textTheme.titleLarge,
//             ),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 TextField(
//                   controller: emailController,
//                   decoration: const InputDecoration(
//                     hintText: 'Enter Email',
//                     prefixIcon: Icon(Icons.search),
//                   ),
//                 ),
//                 SizedBox(height: 2.h),
//                 Text(
//                   'Invite friends to join your spiritual journey',
//                   style: AppTheme.lightTheme.textTheme.bodySmall,
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               Consumer<FriendViewmodel>(
//                 builder: (context, provider, child) {
//                   if (provider.isLoading) {
//                     return CircularProgressIndicator();
//                   }
//                   return ElevatedButton(
//                     onPressed: () {
//                       provider.sendFriendRequestByEmail(
//                         context,
//                         emailController.text ?? "",
//                       );
//                     },
//                     child: const Text('Send Request'),
//                   );
//                 },
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _sendEncouragement(
//     Map<String, dynamic> friend,
//     String type,
//   ) async {
//     try {
//       final today = DateTime.now();
//       final todayString =
//           '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

//       // Check if already sent encouragement today
//       final existingEncouragement =
//           await _firestore
//               .collection('Users')
//               .doc(friend['friendId'])
//               .collection('encouragements')
//               .doc(_currentUserId)
//               .collection('daily')
//               .doc(todayString)
//               .get();

//       if (existingEncouragement.exists) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('You already sent encouragement today')),
//         );
//         return;
//       }

//       // Send encouragement
//       await _firestore
//           .collection('Users')
//           .doc(friend['friendId'])
//           .collection('encouragements')
//           .doc(_currentUserId)
//           .collection('daily')
//           .doc(todayString)
//           .set({'type': type, 'timestamp': FieldValue.serverTimestamp()});

//       String message = '';
//       switch (type) {
//         case 'dua':
//           message = 'Sent a Dua to ${friend['name']}';
//           break;
//         case 'thumbs_up':
//           message = 'Sent encouragement to ${friend['name']}';
//           break;
//         case 'motivational':
//           message = 'Sent motivational message to ${friend['name']}';
//           break;
//       }

//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     } catch (e) {
//       print('Error sending encouragement: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to send encouragement')),
//       );
//     }
//   }

//   Future<void> _removeFriend(Map<String, dynamic> friend) async {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Remove Friend'),
//             content: Text(
//               'Are you sure you want to remove ${friend['name']} from your friends list?',
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   try {
//                     Navigator.pop(context);
//                     setState(() => _isLoading = true);

//                     final batch = _firestore.batch();

//                     // Remove from current user's friends
//                     batch.delete(
//                       _firestore
//                           .collection('Users')
//                           .doc(_currentUserId)
//                           .collection('friends')
//                           .doc(friend['friendId']),
//                     );

//                     // Remove from other user's friends
//                     batch.delete(
//                       _firestore
//                           .collection('Users')
//                           .doc(friend['friendId'])
//                           .collection('friends')
//                           .doc(_currentUserId),
//                     );

//                     await batch.commit();
//                     await _loadFriends();

//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(
//                             '${friend['name']} removed from friends',
//                           ),
//                         ),
//                       );
//                     }
//                   } catch (e) {
//                     print('Error removing friend: $e');
//                     if (mounted) {
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         const SnackBar(
//                           content: Text('Failed to remove friend'),
//                         ),
//                       );
//                     }
//                   } finally {
//                     setState(() => _isLoading = false);
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppTheme.lightTheme.colorScheme.error,
//                 ),
//                 child: const Text('Remove'),
//               ),
//             ],
//           ),
//     );
//   }

//   Future<void> _sendDiscoverFriendRequest(Map<String, dynamic> user) async {
//     try {
//       // Check if request already exists
//       final existingRequest =
//           await _firestore
//               .collection('friend_requests')
//               .where('from', isEqualTo: _currentUserId)
//               .where('to', isEqualTo: user['id'])
//               .limit(1)
//               .get();

//       if (existingRequest.docs.isNotEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Friend request already sent')),
//         );
//         return;
//       }

//       // Send friend request
//       await _firestore.collection('friend_requests').add({
//         'from': _currentUserId,
//         'to': user['id'],
//         'timestamp': FieldValue.serverTimestamp(),
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Friend request sent to ${user['name']}')),
//       );
//     } catch (e) {
//       print('Error sending friend request: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Failed to send friend request')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,

//         title: Text(
//           'Friends',
//           style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
//         ),
//         backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
//         elevation: AppTheme.lightTheme.appBarTheme.elevation,
//         actions: [
//           Stack(
//             children: [
//               IconButton(
//                 onPressed: _showFriendRequests,
//                 icon: CustomIconWidget(
//                   iconName: 'person_add',
//                   color: AppTheme.lightTheme.colorScheme.primary,
//                   size: 24,
//                 ),
//               ),
//               if (_friendRequests.isNotEmpty)
//                 Positioned(
//                   right: 8,
//                   top: 8,
//                   child: Container(
//                     padding: EdgeInsets.all(0.5.w),
//                     decoration: BoxDecoration(
//                       color: AppTheme.lightTheme.colorScheme.error,
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     constraints: BoxConstraints(minWidth: 4.w, minHeight: 4.w),
//                     child: Text(
//                       '${_friendRequests.length}',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 8.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: Size.fromHeight(10.h),
//           child: Column(
//             children: [
//               // Search Bar
//               Container(
//                 margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//                 child: TextField(
//                   controller: _searchController,
//                   onChanged: (value) {
//                     setState(() {
//                       _searchQuery = value;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     hintText: 'Search friends...',
//                     prefixIcon: CustomIconWidget(
//                       iconName: 'search',
//                       color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                       size: 20,
//                     ),
//                     suffixIcon:
//                         _searchQuery.isNotEmpty
//                             ? IconButton(
//                               onPressed: () {
//                                 _searchController.clear();
//                                 setState(() {
//                                   _searchQuery = '';
//                                 });
//                               },
//                               icon: CustomIconWidget(
//                                 iconName: 'clear',
//                                 color:
//                                     AppTheme
//                                         .lightTheme
//                                         .colorScheme
//                                         .onSurfaceVariant,
//                                 size: 20,
//                               ),
//                             )
//                             : null,
//                   ),
//                 ),
//               ),
//               // Tab Bar
//               TabBar(
//                 controller: _tabController,
//                 tabs: const [Tab(text: 'Friends'), Tab(text: 'Discover')],
//               ),
//             ],
//           ),
//         ),
//       ),
//       body:
//           _isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : TabBarView(
//                 controller: _tabController,
//                 children: [_buildFriendsTab(), _buildDiscoverTab()],
//               ),

//       floatingActionButton: FloatingActionButton(
//         onPressed: _showAddFriendDialog,
//         backgroundColor:
//             AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
//         child: CustomIconWidget(
//           iconName: 'person_add',
//           color: AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor!,
//           size: 24,
//         ),
//       ),
//     );
//   }

//   Widget _buildFriendsTab() {
//     if (_filteredFriends.isEmpty && _searchQuery.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomIconWidget(
//               iconName: 'search_off',
//               color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//               size: 48,
//             ),
//             SizedBox(height: 2.h),
//             Text(
//               'No friends found',
//               style: AppTheme.lightTheme.textTheme.titleMedium,
//             ),
//             SizedBox(height: 1.h),
//             Text(
//               'Try searching with a different name or username',
//               style: AppTheme.lightTheme.textTheme.bodySmall,
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       );
//     }

//     if (_friendsList.isEmpty) {
//       return EmptyFriendsStateWidget(onInviteFriends: _showAddFriendDialog);
//     }

//     return RefreshIndicator(
//       onRefresh: _refreshFriends,
//       color: AppTheme.lightTheme.colorScheme.primary,
//       child: ListView.builder(
//         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//         itemCount: _filteredFriends.length,
//         itemBuilder: (context, index) {
//           final friend = _filteredFriends[index];
//           return FriendCardWidget(
//             friend: friend,
//             onSendEncouragement: (type) => _sendEncouragement(friend, type),
//             onRemoveFriend: () => _removeFriend(friend),
//             onViewProfile: () {
//               Navigator.pushNamed(context, '/analytics-dashboard');
//             },
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildDiscoverTab() {
//     if (_discoverUsers.isEmpty) {
//       return const Center(child: Text('No Users to discover'));
//     }

//     return ListView(
//       padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
//       children: [
//         Text(
//           'Suggested Friends',
//           style: AppTheme.lightTheme.textTheme.titleMedium,
//         ),
//         SizedBox(height: 2.h),
//         ..._discoverUsers.map(
//           (suggestion) => Card(
//             margin: EdgeInsets.only(bottom: 2.h),
//             child: ListTile(
//               leading: CircleAvatar(
//                 radius: 6.w,
//                 backgroundImage:
//                     suggestion['profileImage'].isNotEmpty
//                         ? NetworkImage(suggestion['profileImage'])
//                         : null,
//                 child:
//                     suggestion['profileImage'].isEmpty
//                         ? Icon(Icons.person, size: 6.w)
//                         : null,
//               ),
//               title: Text(
//                 suggestion['name'],
//                 style: AppTheme.lightTheme.textTheme.titleSmall,
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     suggestion['username'],
//                     style: AppTheme.lightTheme.textTheme.bodySmall,
//                   ),
//                   Text(
//                     '${suggestion['mutualFriends']} mutual friends • ${suggestion['location']}',
//                     style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                       color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                 ],
//               ),
//               trailing: ElevatedButton(
//                 onPressed: () => _sendDiscoverFriendRequest(suggestion),
//                 style: ElevatedButton.styleFrom(minimumSize: Size(20.w, 5.h)),
//                 child: const Text('Add'),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// String timeAgo(DateTime dateTime) {
//   final now = DateTime.now();
//   final difference = now.difference(dateTime);

//   if (difference.inSeconds < 60) return 'Just now';
//   if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
//   if (difference.inHours < 24) {
//     return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
//   }
//   if (difference.inDays < 7) {
//     return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
//   }
//   return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
// }





