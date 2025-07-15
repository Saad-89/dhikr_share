import 'package:dhikar_share/view/friends/widgets/friend_tile.dart';
import 'package:dhikar_share/view/friends/widgets/sync_contact_button.dart';
import 'package:dhikar_share/view/onBoarding/intention_remainder/intention_remainder_screen.dart';
import 'package:flutter/material.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:dhikar_share/widgets/flat_app_button.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';

class AddFriendsScreen extends StatelessWidget {
  const AddFriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IntentionReminderScreen(),
                      ),
                    );
                  },
                  child: AppText(
                    text: "Skip →",
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: AppText(
                  text: "Add friends to\nRemember Allah together!",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: AppText(
                  text:
                      "See who's already on Dhikr Share or invite\nsomeone to join",
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                  color: AppColors.black54,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              SyncContactsButton(onPressed: () {}),
              const SizedBox(height: 12),

              // FlatAppButton(
              //   text: "Invite via Link",
              //   onPressed: () {},
              //   color: Colors.white,
              //   textColor: AppColors.black,
              // ),
              const SizedBox(height: 24),

              // Friends List
              FriendTile(
                name: "Ahmed",
                subtitle: "3,200 dhikr this week 👐",
                buttonText: "Add Friend",
                onTap: () {},
              ),
              FriendTile(
                name: "Mom",
                subtitle: "Invite Hamza to Dhikr Share!",
                buttonText: "Invite",
                onTap: () {},
              ),
              FriendTile(
                name: "Abdullah",
                subtitle: "Invite Abdullah to Dhikr Share!",
                buttonText: "Invite",
                onTap: () {},
              ),
              FriendTile(
                name: "Hasan",
                subtitle: "Invite Hasan to Dhikr Share!",
                buttonText: "Invite",
                onTap: () {},
              ),
              FriendTile(
                name: "Hamza",
                subtitle: "Invite Hamza to Dhikr Share!",
                buttonText: "Invite",
                onTap: () {},
              ),

              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => IntentionReminderScreen(),
                      ),
                    );
                  },
                  child: AppText(
                    text: "Skip",
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: AppColors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
