import 'package:dhikar_share/view/onBoarding/Dhkir_goal/loading_screen.dart';
import 'package:dhikar_share/view/onBoarding/permission/allow_access_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_button.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/services.dart'; // For HapticFeedback

class SetGoalScreen extends StatefulWidget {
  const SetGoalScreen({super.key});

  @override
  State<SetGoalScreen> createState() => _SetGoalScreenState();
}

class _SetGoalScreenState extends State<SetGoalScreen> {
  int _goal = 1000;
  int _selectedIndex = 9; // Default to 1000 (index 9)

  void _showGoalPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: AppColors.white,
      builder: (_) {
        return Container(
          height: 300,
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: AppText(
                        text: 'Cancel',
                        fontSize: 16,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const AppText(
                      text: 'Select Goal',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _goal = (_selectedIndex + 1) * 100;
                        });
                        HapticFeedback.mediumImpact();
                        Navigator.pop(context);
                      },
                      child: AppText(
                        text: 'Done',
                        fontSize: 16,
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Cupertino Picker
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 40,
                  scrollController: FixedExtentScrollController(
                    initialItem: _selectedIndex,
                  ),
                  onSelectedItemChanged: (index) {
                    _selectedIndex = index;
                    // Trigger haptic feedback on each scroll
                    HapticFeedback.selectionClick();
                  },
                  children: List.generate(200, (index) {
                    int goal = (index + 1) * 100;
                    return Center(
                      child: AppText(
                        text: '$goal',
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppText(
                  text: 'Set Your Daily Dhikr Goal',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Hadith Card
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Column(
                    children: [
                      AppText(
                        text:
                            '"The most beloved deeds to Allah\nare those done consistently."',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      AppText(
                        text: '– Bukhari',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black54,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Goal Selector
                GestureDetector(
                  onTap: () => _showGoalPicker(context),
                  child: Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4ED),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text: _goal.toString(),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Goal Button
                AppButton(
                  text: 'Save Goal',
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 50,
                  onPressed: () {
                    // Save goal action
                    print('Goal saved: $_goal');
                    // Add haptic feedback for successful save
                    HapticFeedback.lightImpact();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoadingScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                const AppText(
                  text: 'You can always change this later.',
                  fontSize: 14,
                  color: AppColors.black54,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Skip for now
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AllowAccessScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:dhikar_share/view/onBoarding/Dhkir_goal/loading_screen.dart';
// import 'package:dhikar_share/view/onBoarding/permission/allow_access_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:dhikar_share/core/constants/app_colors.dart';
// import 'package:dhikar_share/widgets/app_button.dart';
// import 'package:dhikar_share/widgets/app_text.dart';
// import 'package:flutter/services.dart'; // For HapticFeedback

// class SetGoalScreen extends StatefulWidget {
//   const SetGoalScreen({super.key});

//   @override
//   State<SetGoalScreen> createState() => _SetGoalScreenState();
// }

// class _SetGoalScreenState extends State<SetGoalScreen> {
//   int _goal = 1000;

//   void _showGoalPicker(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return SizedBox(
//           height: 300,
//           child: ListView.builder(
//             itemCount: 200, // 200 * 100 = 20,000 max
//             itemBuilder: (context, index) {
//               int goal = (index + 1) * 100;
//               return ListTile(
//                 title: Center(
//                   child: Text(
//                     '$goal',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//                 onTap: () {
//                   setState(() {
//                     _goal = goal;
//                   });
//                   HapticFeedback.mediumImpact(); // Trigger native vibration
//                   Navigator.pop(context);
//                 },
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.white,
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const AppText(
//                   text: 'Set Your Daily Dhikr Goal',
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 24),

//                 // Hadith Card
//                 Container(
//                   padding: const EdgeInsets.all(32),
//                   decoration: BoxDecoration(
//                     color: AppColors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black12,
//                         blurRadius: 10,
//                         offset: Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: const Column(
//                     children: [
//                       AppText(
//                         text:
//                             '“The most beloved deeds to Allah\nare those done consistently.”',
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 8),
//                       AppText(
//                         text: '– Bukhari',
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                         color: AppColors.black54,
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 32),

//                 // Goal Selector
//                 GestureDetector(
//                   onTap: () => _showGoalPicker(context),
//                   child: Container(
//                     width: 150,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFEAF4ED),
//                       borderRadius: BorderRadius.circular(30),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         AppText(
//                           text: _goal.toString(),
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(Icons.arrow_drop_down),
//                       ],
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // Save Goal Button
//                 AppButton(
//                   text: 'Save Goal',
//                   width: MediaQuery.of(context).size.width * 0.6,
//                   height: 50,
//                   onPressed: () {
//                     // Save goal action
//                     print('Goal saved: $_goal');
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => LoadingScreen()),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 const AppText(
//                   text: 'You can always change this later.',
//                   fontSize: 14,
//                   color: AppColors.black54,
//                   textAlign: TextAlign.center,
//                 ),

//                 const SizedBox(height: 32),

//                 // Skip for now
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => AllowAccessScreen(),
//                       ),
//                     );
//                   },
//                   child: const Text(
//                     'Skip for now',
//                     style: TextStyle(
//                       color: Colors.grey,
//                       fontSize: 14,
//                       decoration: TextDecoration.underline,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
