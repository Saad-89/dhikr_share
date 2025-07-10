import 'package:dhikr_share/domain/models/friend_request_model.dart';
import 'package:dhikr_share/presentation/viewmodels/friend_viewmodel.dart';
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
  bool _isLoading = false;
  String _searchQuery = '';

  // Mock data for friends
  final List<Map<String, dynamic>> _friendsList = [
    {
      "id": 1,
      "name": "Ahmed Hassan",
      "username": "@ahmed_hassan",
      "profileImage":
          "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400",
      "todayDhikr": 247,
      "lastActive": "2 hours ago",
      "isOnline": true,
      "privacyLevel": "public",
      "weeklyProgress": [45, 67, 89, 123, 156, 189, 247],
      "achievements": ["7-Day Streak", "Morning Dhikr Champion"],
    },
    {
      "id": 2,
      "name": "Fatima Al-Zahra",
      "username": "@fatima_zahra",
      "profileImage":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "todayDhikr": 189,
      "lastActive": "30 minutes ago",
      "isOnline": true,
      "privacyLevel": "friends",
      "weeklyProgress": [34, 56, 78, 98, 134, 167, 189],
      "achievements": ["Consistent Worshipper", "Evening Dhikr Master"],
    },
    {
      "id": 3,
      "name": "Omar Abdullah",
      "username": "@omar_abdullah",
      "profileImage":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "todayDhikr": 0,
      "lastActive": "1 day ago",
      "isOnline": false,
      "privacyLevel": "private",
      "weeklyProgress": [23, 45, 67, 89, 112, 134, 0],
      "achievements": ["Weekend Warrior"],
    },
    {
      "id": 4,
      "name": "Aisha Rahman",
      "username": "@aisha_rahman",
      "profileImage":
          "https://images.pexels.com/photos/1130626/pexels-photo-1130626.jpeg?auto=compress&cs=tinysrgb&w=400",
      "todayDhikr": 312,
      "lastActive": "5 minutes ago",
      "isOnline": true,
      "privacyLevel": "public",
      "weeklyProgress": [78, 98, 123, 156, 189, 234, 312],
      "achievements": ["Daily Champion", "Dhikr Master", "Community Leader"],
    },
  ];

  final List<Map<String, dynamic>> _friendRequests = [
    {
      "id": 5,
      "name": "Yusuf Ibrahim",
      "username": "@yusuf_ibrahim",
      "profileImage":
          "https://images.pexels.com/photos/1681010/pexels-photo-1681010.jpeg?auto=compress&cs=tinysrgb&w=400",
      "mutualFriends": 3,
      "requestTime": "2 hours ago",
    },
    {
      "id": 6,
      "name": "Khadija Malik",
      "username": "@khadija_malik",
      "profileImage":
          "https://images.pexels.com/photos/1542085/pexels-photo-1542085.jpeg?auto=compress&cs=tinysrgb&w=400",
      "mutualFriends": 1,
      "requestTime": "1 day ago",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FriendViewmodel>(context, listen: false).loadFriendRequests();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFriends {
    if (_searchQuery.isEmpty) return _friendsList;
    return _friendsList.where((friend) {
      final name = (friend['name'] as String).toLowerCase();
      final username = (friend['username'] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || username.contains(query);
    }).toList();
  }

  Future<void> _refreshFriends() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });
  }

  void _showFriendRequests() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => FriendRequestBottomSheet(
            friendRequests: _friendRequests,
            onAcceptRequest: _acceptFriendRequest,
            onDeclineRequest: _declineFriendRequest,
          ),
    );
  }

  void _acceptFriendRequest(Map<String, dynamic> request) {
    setState(() {
      _friendRequests.removeWhere((req) => req['id'] == request['id']);
      _friendsList.add({
        ...request,
        "todayDhikr": 0,
        "lastActive": "Just joined",
        "isOnline": true,
        "privacyLevel": "friends",
        "weeklyProgress": [0, 0, 0, 0, 0, 0, 0],
        "achievements": [],
      });
    });
    Navigator.pop(context);
  }

  void _declineFriendRequest(Map<String, dynamic> request) {
    setState(() {
      _friendRequests.removeWhere((req) => req['id'] == request['id']);
    });
    Navigator.pop(context);
  }

  void _showAddFriendDialog() {
    final emailController = TextEditingController();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                    return CircularProgressIndicator();
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

  void _sendEncouragement(Map<String, dynamic> friend, String type) {
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _removeFriend(Map<String, dynamic> friend) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
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
                onPressed: () {
                  setState(() {
                    _friendsList.removeWhere((f) => f['id'] == friend['id']);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${friend['name']} removed from friends'),
                    ),
                  );
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
          Stack(
            children: [
              IconButton(
                onPressed: _showFriendRequests,
                icon: CustomIconWidget(
                  iconName: 'person_add',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 24,
                ),
              ),
              if (_friendRequests.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(0.5.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: BoxConstraints(minWidth: 4.w, minHeight: 4.w),
                    child: Text(
                      '${_friendRequests.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(15.h),
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
                    suffixIcon:
                        _searchQuery.isNotEmpty
                            ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: CustomIconWidget(
                                iconName: 'clear',
                                color:
                                    AppTheme
                                        .lightTheme
                                        .colorScheme
                                        .onSurfaceVariant,
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
        children: [
          // Friends Tab
          _buildFriendsTab(),
          // Discover Tab
          _buildDiscoverTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor:
            AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
        child: CustomIconWidget(
          iconName: 'person_add',
          color: AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor!,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    if (_filteredFriends.isEmpty && _searchQuery.isNotEmpty) {
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

    if (_friendsList.isEmpty) {
      return EmptyFriendsStateWidget(onInviteFriends: _showAddFriendDialog);
    }

    return RefreshIndicator(
      onRefresh: _refreshFriends,
      color: AppTheme.lightTheme.colorScheme.primary,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        itemCount: _filteredFriends.length,
        itemBuilder: (context, index) {
          final friend = _filteredFriends[index];
          return FriendCardWidget(
            friend: friend,
            onSendEncouragement: (type) => _sendEncouragement(friend, type),
            onRemoveFriend: () => _removeFriend(friend),
            onViewProfile: () {
              Navigator.pushNamed(context, '/analytics-dashboard');
            },
          );
        },
      ),
    );
  }

  Widget _buildDiscoverTab() {
    final List<Map<String, dynamic>> suggestedFriends = [
      {
        "id": 7,
        "name": "Hassan Ali",
        "username": "@hassan_ali",
        "profileImage":
            "https://images.pexels.com/photos/1040880/pexels-photo-1040880.jpeg?auto=compress&cs=tinysrgb&w=400",
        "mutualFriends": 5,
        "location": "Same city",
      },
      {
        "id": 8,
        "name": "Maryam Qureshi",
        "username": "@maryam_qureshi",
        "profileImage":
            "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
        "mutualFriends": 2,
        "location": "Nearby",
      },
    ];

    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      children: [
        Text(
          'Suggested Friends',
          style: AppTheme.lightTheme.textTheme.titleMedium,
        ),
        SizedBox(height: 2.h),
        ...suggestedFriends.map(
          (suggestion) => Card(
            margin: EdgeInsets.only(bottom: 2.h),
            child: ListTile(
              leading: CircleAvatar(
                radius: 6.w,
                backgroundImage: NetworkImage(suggestion['profileImage']),
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
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Friend request sent to ${suggestion['name']}',
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(minimumSize: Size(20.w, 5.h)),
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String timeAgo(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inSeconds < 60) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
  if (difference.inHours < 24) return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
  if (difference.inDays < 7) return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
}
