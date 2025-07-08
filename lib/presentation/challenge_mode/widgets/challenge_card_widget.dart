import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ChallengeCardWidget extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final VoidCallback onTap;

  const ChallengeCardWidget({
    super.key,
    required this.challenge,
    required this.onTap,
  });

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty?.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Responsive sizing helpers
  double get _cardHeight {
    if (100.w < 600) return 28.h; // Mobile
    if (100.w < 900) return 25.h; // Tablet portrait
    return 22.h; // Tablet landscape / Desktop
  }

  double get _horizontalPadding {
    if (100.w < 600) return 4.w; // Mobile
    if (100.w < 900) return 3.w; // Tablet portrait
    return 2.w; // Tablet landscape / Desktop
  }

  double get _verticalPadding {
    if (100.w < 600) return 2.h; // Mobile
    return 1.5.h; // Tablet / Desktop
  }

  double get _badgePadding {
    if (100.w < 600) return 2.w; // Mobile
    return 1.5.w; // Tablet / Desktop
  }

  double get _iconSize {
    if (100.w < 600) return 14.0; // Mobile
    if (100.w < 900) return 16.0; // Tablet portrait
    return 18.0; // Tablet landscape / Desktop
  }

  double get _smallIconSize {
    if (100.w < 600) return 12.0; // Mobile
    if (100.w < 900) return 14.0; // Tablet portrait
    return 16.0; // Tablet landscape / Desktop
  }

  @override
  Widget build(BuildContext context) {
    final isGroupChallenge = challenge["type"] == "group";
    final difficultyColor = _getDifficultyColor(challenge["difficulty"]);

    return Container(
      margin: EdgeInsets.only(bottom: 3.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: _cardHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: challenge["backgroundImage"] != null
                  ? DecorationImage(
                      image: NetworkImage(challenge["backgroundImage"]),
                      fit: BoxFit.cover,
                    )
                  : null,
              color: challenge["backgroundImage"] == null
                  ? AppTheme.lightTheme.colorScheme.surface
                  : null,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _horizontalPadding,
                  vertical: _verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header badges
                    _buildHeaderBadges(isGroupChallenge, difficultyColor),

                    Spacer(),

                    // Challenge content
                    Expanded(flex: 3, child: _buildChallengeContent()),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderBadges(bool isGroupChallenge, Color difficultyColor) {
    return Row(
      children: [
        // Challenge type badge
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _badgePadding,
              vertical: 0.5.h,
            ),
            decoration: BoxDecoration(
              color: isGroupChallenge
                  ? AppTheme.lightTheme.colorScheme.secondary
                  : AppTheme.lightTheme.colorScheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: isGroupChallenge ? 'group' : 'person',
                  color: Colors.white,
                  size: _smallIconSize,
                ),
                SizedBox(width: 1.w),
                Flexible(
                  child: Text(
                    isGroupChallenge ? "Group" : "Solo",
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 100.w < 600 ? 10.sp : 12.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 2.w),

        // Difficulty badge
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _badgePadding,
              vertical: 0.5.h,
            ),
            decoration: BoxDecoration(
              color: difficultyColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              challenge["difficulty"] ?? "",
              style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 100.w < 600 ? 10.sp : 12.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        Spacer(),

        // Arrow icon
        Container(
          padding: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: 'arrow_forward',
            color: Colors.white,
            size: _iconSize,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          challenge["title"] ?? "",
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 100.w < 600
                ? 18.sp
                : 100.w < 900
                ? 20.sp
                : 22.sp,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 1.h),

        // Description
        Text(
          challenge["description"] ?? "",
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 100.w < 600
                ? 12.sp
                : 100.w < 900
                ? 14.sp
                : 16.sp,
          ),
          maxLines: 100.w < 600 ? 1 : 2,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 1.5.h),

        // Stats row
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [
            _buildStatChip(
              icon: 'schedule',
              text: challenge["estimatedTime"] ?? "",
            ),
            _buildStatChip(icon: 'flag', text: "${challenge["target"]} target"),
          ],
        ),

        SizedBox(height: 1.h),

        // Spiritual benefit preview
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: _badgePadding,
            vertical: 0.5.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'auto_awesome',
                color: Colors.white,
                size: _smallIconSize,
              ),
              SizedBox(width: 1.w),
              Expanded(
                child: Text(
                  challenge["spiritualBenefit"] ?? "",
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontSize: 100.w < 600 ? 13.sp : 15.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({required String icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: _badgePadding, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: _smallIconSize,
          ),
          SizedBox(width: 1.w),
          Text(
            text,
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 100.w < 600 ? 14.sp : 16.sp,
            ),
          ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';

// import '../../../core/app_export.dart';

// class ChallengeCardWidget extends StatelessWidget {
//   final Map<String, dynamic> challenge;
//   final VoidCallback onTap;

//   const ChallengeCardWidget({
//     super.key,
//     required this.challenge,
//     required this.onTap,
//   });

//   Color _getDifficultyColor(String? difficulty) {
//     switch (difficulty?.toLowerCase()) {
//       case 'easy':
//         return Colors.green;
//       case 'medium':
//         return Colors.orange;
//       case 'hard':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isGroupChallenge = challenge["type"] == "group";
//     final difficultyColor = _getDifficultyColor(challenge["difficulty"]);

//     return Container(
//       margin: EdgeInsets.only(bottom: 3.h),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             height: 25.h,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16),
//               image: challenge["backgroundImage"] != null
//                   ? DecorationImage(
//                       image: NetworkImage(challenge["backgroundImage"]),
//                       fit: BoxFit.cover,
//                     )
//                   : null,
//               color: challenge["backgroundImage"] == null
//                   ? AppTheme.lightTheme.colorScheme.surface
//                   : null,
//             ),
//             child: Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16),
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Colors.black.withValues(alpha: 0.2),
//                     Colors.black.withValues(alpha: 0.7),
//                   ],
//                 ),
//               ),
//               child: Padding(
//                 padding: EdgeInsets.all(4.w),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // Header badges
//                     Row(
//                       children: [
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 2.w,
//                             vertical: 0.5.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: isGroupChallenge
//                                 ? AppTheme.lightTheme.colorScheme.secondary
//                                 : AppTheme.lightTheme.colorScheme.primary,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               CustomIconWidget(
//                                 iconName: isGroupChallenge ? 'group' : 'person',
//                                 color: Colors.white,
//                                 size: 12,
//                               ),
//                               SizedBox(width: 1.w),
//                               Text(
//                                 isGroupChallenge ? "Group" : "Solo",
//                                 style: AppTheme.lightTheme.textTheme.labelSmall
//                                     ?.copyWith(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         SizedBox(width: 2.w),
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 2.w,
//                             vertical: 0.5.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: difficultyColor,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             challenge["difficulty"] ?? "",
//                             style: AppTheme.lightTheme.textTheme.labelSmall
//                                 ?.copyWith(
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                           ),
//                         ),
//                         Spacer(),
//                         Container(
//                           padding: EdgeInsets.all(1.w),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.2),
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: CustomIconWidget(
//                             iconName: 'arrow_forward',
//                             color: Colors.white,
//                             size: 16,
//                           ),
//                         ),
//                       ],
//                     ),
//                     Spacer(),

//                     // Challenge content
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           challenge["title"] ?? "",
//                           style: AppTheme.lightTheme.textTheme.titleLarge
//                               ?.copyWith(
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 1.h),
//                         Text(
//                           challenge["description"] ?? "",
//                           style: AppTheme.lightTheme.textTheme.bodyMedium
//                               ?.copyWith(
//                                 color: Colors.white.withValues(alpha: 0.9),
//                               ),
//                           maxLines: 2,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         SizedBox(height: 2.h),

//                         // Stats row
//                         Row(
//                           children: [
//                             _buildStatChip(
//                               icon: 'schedule',
//                               text: challenge["estimatedTime"] ?? "",
//                             ),
//                             SizedBox(width: 2.w),
//                             _buildStatChip(
//                               icon: 'flag',
//                               text: "${challenge["target"]} target",
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 1.h),

//                         // Spiritual benefit preview
//                         Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 2.w,
//                             vertical: 0.5.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(8),
//                             border: Border.all(
//                               color: Colors.white.withValues(alpha: 0.3),
//                             ),
//                           ),
//                           child: Row(
//                             children: [
//                               CustomIconWidget(
//                                 iconName: 'auto_awesome',
//                                 color: Colors.white,
//                                 size: 14,
//                               ),
//                               SizedBox(width: 1.w),
//                               Expanded(
//                                 child: Text(
//                                   challenge["spiritualBenefit"] ?? "",
//                                   style: AppTheme
//                                       .lightTheme
//                                       .textTheme
//                                       .labelSmall
//                                       ?.copyWith(color: Colors.white),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStatChip({required String icon, required String text}) {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
//       decoration: BoxDecoration(
//         color: Colors.white.withValues(alpha: 0.2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CustomIconWidget(iconName: icon, color: Colors.white, size: 12),
//           SizedBox(width: 1.w),
//           Text(
//             text,
//             style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
//               color: Colors.white,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
