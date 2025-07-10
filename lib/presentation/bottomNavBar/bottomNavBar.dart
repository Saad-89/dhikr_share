import 'package:dhikr_share/presentation/analytics_dashboard/analytics_dashboard.dart';
import 'package:dhikr_share/presentation/challenge_mode/challenge_mode.dart';
import 'package:dhikr_share/presentation/friends_list/friends_list.dart';
import 'package:dhikr_share/presentation/main_dhikr_counter/main_dhikr_counter.dart';
import 'package:dhikr_share/presentation/settings/settings.dart';
import 'package:dhikr_share/theme/app_theme.dart';
import 'package:dhikr_share/widgets/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class BottomNavScreen extends StatefulWidget {
  const BottomNavScreen({super.key});

  @override
  State<BottomNavScreen> createState() => _BottomNavScreenState();
}

class _BottomNavScreenState extends State<BottomNavScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    MainDhikrCounter(),
    FriendsList(),
    AnalyticsDashboard(friendsAnalyticScreen: true),
    ChallengeMode(),
    Settings(),
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
        selectedItemColor: AppTheme.lightTheme.primaryColor,
        unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurface
            .withOpacity(0.6),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 8,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'home',
              color: _selectedIndex == 0
                  ? AppTheme.lightTheme.primaryColor
                  : null,
              size: 24,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'people',
              color: _selectedIndex == 1
                  ? AppTheme.lightTheme.primaryColor
                  : null,
              size: 24,
            ),
            label: 'Friends',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: _selectedIndex == 2
                  ? AppTheme.lightTheme.primaryColor
                  : null,
              size: 24,
            ),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'emoji_events',
              color: _selectedIndex == 3
                  ? AppTheme.lightTheme.primaryColor
                  : null,
              size: 24,
            ),
            label: 'Challenges',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: _selectedIndex == 4
                  ? AppTheme.lightTheme.primaryColor
                  : null,
              size: 24,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
