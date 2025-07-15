import 'package:dhikar_share/view/friends/add_friend_screen.dart';
import 'package:dhikar_share/view/onBoarding/intention_remainder/intention_remainder_screen.dart';
import 'package:dhikar_share/view/onBoarding/permission/widgets/permission_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:dhikar_share/widgets/app_button.dart';

class AllowAccessScreen extends StatefulWidget {
  const AllowAccessScreen({super.key});

  @override
  State<AllowAccessScreen> createState() => _AllowAccessScreenState();
}

class _AllowAccessScreenState extends State<AllowAccessScreen> {
  bool voiceDetection = false;
  bool reminders = false;
  bool locationAccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Set your app's background color
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              const AppText(
                text: 'Allow Access',
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 12),
              const AppText(
                text:
                    'To use voice dhikr and reminders,\nwe need a couple of permissions',
                fontSize: 14,
                fontWeight: FontWeight.normal,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Permission Tiles
              PermissionTile(
                icon: Icons.mic,
                text: 'Enable voice dhikr detection',
                isEnabled: voiceDetection,
                onChanged: (val) => setState(() => voiceDetection = val),
              ),
              PermissionTile(
                icon: Icons.notifications_active,
                text: 'Get gentle reminders and\nprogress updates',
                isEnabled: reminders,
                onChanged: (val) => setState(() => reminders = val),
              ),
              PermissionTile(
                icon: Icons.location_on,
                text: 'Access location for local\nprayer times',
                isEnabled: locationAccess,
                onChanged: (val) => setState(() => locationAccess = val),
              ),
              SizedBox(height: 16),
              // const Spacer(),

              // Continue Button
              AppButton(
                width: MediaQuery.of(context).size.width,
                height: 50,
                text: 'Continue',
                onPressed: () {
                  // Handle continue or permissions logic
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFriendsScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Later Text
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddFriendsScreen()),
                  );
                },
                child: AppText(
                  text: "I'll enable this later",
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColors.black54,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
