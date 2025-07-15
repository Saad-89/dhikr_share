import 'package:dhikar_share/view/BottomNav/bottom_navigation.dart';
import 'package:dhikar_share/view/Quizes/dhikr_plan_ready_screen.dart/widgets/daily_goal_circle.dart';
import 'package:dhikar_share/view/Quizes/dhikr_plan_ready_screen.dart/widgets/dhikr_goals_item.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class DhikrPlanReadyScreen extends StatelessWidget {
  const DhikrPlanReadyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Center(
          child: Container(
            // margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            // decoration: BoxDecoration(
            //   color: Colors.white,
            //   borderRadius: BorderRadius.circular(24),
            //   boxShadow: [
            //     BoxShadow(
            //       color: Colors.black.withOpacity(0.08),
            //       blurRadius: 20,
            //       offset: const Offset(0, 4),
            //     ),
            //   ],
            // ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: AppText(
                        text: "🎉 Your Dhikr Plan is Ready,\n in shā' Allāh",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Subtitle
                AppText(
                  text: "A simple daily rhythm, just for you.",
                  fontSize: 14,
                  color: Colors.grey[600],
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),
                Container(
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Goal items with exact icons and layout
                      DhikrGoalItem(
                        leftIcon: Icons.wb_sunny,
                        rightIcon: Icons.terrain,
                        count: "200",
                        description: "after Fajr",
                      ),

                      DhikrGoalItem(
                        leftIcon: Icons.directions_car,
                        rightIcon: Icons.directions_car,
                        count: "300",
                        description: "during commute",
                      ),

                      DhikrGoalItem(
                        leftIcon: Icons.nightlight_round,
                        rightIcon: Icons.bed,
                        count: "500",
                        description: "before bed",
                      ),
                      SizedBox(height: 40),

                      // Daily goal circle
                      DailyGoalCircle(current: 0, total: 1000),
                      const SizedBox(height: 12),

                      AppText(
                        text: "Daily Goal",
                        fontSize: 14,
                        color: Colors.grey[600],
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Button with exact styling
                AppButton(
                  text: "Let's Begin",
                  width: double.infinity,
                  height: 52,

                  onPressed: () {
                    // Your navigation logic here
                    print("Let's Begin pressed");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BottomNavScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Footer quote
                AppText(
                  text: "Even hidden dhikr is seen by Him.",
                  fontSize: 12,
                  color: Colors.grey[500],
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
