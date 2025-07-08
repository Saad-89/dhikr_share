// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';

// import '../../../core/app_export.dart';
// import '../../../services/auth_service.dart';

// class SocialLoginWidget extends StatelessWidget {
//   final VoidCallback onGoogleLogin;
//   final VoidCallback onAppleLogin;

//   const SocialLoginWidget({
//     super.key,
//     required this.onGoogleLogin,
//     required this.onAppleLogin,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // final authService = AuthService();

//     return Column(
//       children: [
//         // Google Sign In Button
//         if (authService.supportsGoogleSignIn)
//           _buildSocialButton(
//             onTap: onGoogleLogin,
//             icon: 'google',
//             label: 'Continue with Google',
//             backgroundColor: Colors.white,
//             textColor: AppTheme.lightTheme.colorScheme.onSurface,
//             borderColor: AppTheme.lightTheme.colorScheme.outline,
//           ),

//         // Apple Sign In Button (iOS only)
//         if (authService.supportsAppleSignIn) ...[
//           if (authService.supportsGoogleSignIn) SizedBox(height: 2.h),
//           _buildSocialButton(
//             onTap: onAppleLogin,
//             icon: 'apple',
//             label: 'Continue with Apple',
//             backgroundColor: Colors.black,
//             textColor: Colors.white,
//             borderColor: Colors.black,
//           ),
//         ],

//         // If neither social login is available, show placeholder
//         if (!authService.supportsGoogleSignIn &&
//             !authService.supportsAppleSignIn)
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.symmetric(vertical: 2.h),
//             decoration: BoxDecoration(
//               color: AppTheme.lightTheme.colorScheme.surfaceContainerHighest,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: AppTheme.lightTheme.colorScheme.outline,
//               ),
//             ),
//             child: Center(
//               child: Text(
//                 'Social login not available on this platform',
//                 style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
//                   color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildSocialButton({
//     required VoidCallback onTap,
//     required String icon,
//     required String label,
//     required Color backgroundColor,
//     required Color textColor,
//     required Color borderColor,
//   }) {
//     return SizedBox(
//       width: double.infinity,
//       height: 6.h,
//       child: Material(
//         color: backgroundColor,
//         borderRadius: BorderRadius.circular(12),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(12),
//           onTap: onTap,
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: borderColor),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 CustomIconWidget(iconName: icon, size: 5.w, color: textColor),
//                 SizedBox(width: 3.w),
//                 Text(
//                   label,
//                   style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
//                     color: textColor,
//                     fontWeight: FontWeight.w500,
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
