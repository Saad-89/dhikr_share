import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/view/analytics_dashboard/analytic_dashboard.dart';
import 'package:dhikar_share/view/challenges/challenges_screen.dart';
import 'package:dhikar_share/view/dashboard/main_dashboard_screen.dart';
import 'package:dhikar_share/view/friends/friend_list.dart';
import 'package:dhikar_share/view/setting/setting_screen.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MainDashboardScreen(),
    FriendsList(),
    AnalyticsDashboard(),
    ChallengesScreen(),
    SettingScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.grey.withOpacity(0.6),
        backgroundColor: AppColors.white,
        elevation: 8,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home,

              color: _selectedIndex == 0 ? AppColors.primaryGreen : null,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
              color: _selectedIndex == 1 ? AppColors.primaryGreen : null,
              size: 24,
            ),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.analytics,
              color: _selectedIndex == 2 ? AppColors.primaryGreen : null,
              size: 24,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.emoji_events,
              color: _selectedIndex == 3 ? AppColors.primaryGreen : null,
              size: 24,
            ),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: _selectedIndex == 4 ? AppColors.primaryGreen : null,
              size: 24,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
