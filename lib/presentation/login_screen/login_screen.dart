import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import './widgets/islamic_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  bool _rememberMe = false;

  // final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    final savedPassword = prefs.getString('saved_password');

    if (savedEmail != null && savedPassword != null) {
      _emailController.text = savedEmail;
      _passwordController.text = savedPassword;
      setState(() {
        _rememberMe = true;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  // Future<void> _handleLogin() async {
  //   if (!_formKey.currentState!.validate()) {
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final email = _emailController.text.trim();
  //     final password = _passwordController.text;

  //     final response = await _authService.signInWithEmail(
  //       email: email,
  //       password: password,
  //       rememberMe: _rememberMe,
  //     );

  //     if (response.user != null) {
  //       // Success - provide haptic feedback
  //       HapticFeedback.lightImpact();

  //       // Mark user as not first time
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setBool('is_first_time', false);

  //       // Show brief success message
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(
  //             content: Text(
  //               'Bismillah - Welcome back!',
  //               style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
  //                 color: Colors.white,
  //               ),
  //             ),
  //             backgroundColor: AppTheme.lightTheme.colorScheme.primary,
  //             duration: const Duration(seconds: 1),
  //           ),
  //         );

  //         // Navigate to main dhikr counter
  //         await Future.delayed(const Duration(milliseconds: 500));
  //         Navigator.pushReplacementNamed(context, '/main-dhikr-counter');
  //       }
  //     }
  //   } catch (e) {
  //     // Show error message
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text(
  //             'Login failed: ${e.toString()}',
  //             style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
  //               color: Colors.white,
  //             ),
  //           ),
  //           backgroundColor: AppTheme.lightTheme.colorScheme.error,
  //           duration: const Duration(seconds: 3),
  //         ),
  //       );
  //     }
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  // void _handleForgotPassword() async {
  //   if (_emailController.text.isEmpty) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Please enter your email address first')),
  //     );
  //     return;
  //   }

  //   try {
  //     await _authService.resetPassword(_emailController.text.trim());
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Text(
  //             'Password reset email sent. Please check your inbox.',
  //           ),
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Error: ${e.toString()}'),
  //           backgroundColor: AppTheme.lightTheme.colorScheme.error,
  //         ),
  //       );
  //     }
  //   }
  // }

  // void _handleSocialLogin(String provider) async {
  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     switch (provider.toLowerCase()) {
  //       case 'google':
  //         final response = await _authService.signInWithGoogle();
  //         if (response?.user != null) {
  //           _navigateToHome();
  //         }
  //         break;
  //       case 'apple':
  //         if (_authService.supportsAppleSignIn) {
  //           final response = await _authService.signInWithApple();
  //           if (response?.user != null) {
  //             _navigateToHome();
  //           }
  //         } else {
  //           _showUnsupportedMessage(
  //             'Apple Sign In is only available on iOS devices',
  //           );
  //         }
  //         break;
  //       default:
  //         _showUnsupportedMessage('$provider login will be available soon.');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('$provider login failed: ${e.toString()}'),
  //           backgroundColor: AppTheme.lightTheme.colorScheme.error,
  //         ),
  //       );
  //     }
  //   }

  //   setState(() {
  //     _isLoading = false;
  //   });
  // }

  void _navigateToHome() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', false);

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/main-dhikr-counter');
    }
  }

  void _showUnsupportedMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _navigateToRegistration() {
    Navigator.pushNamed(context, '/islamic-onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // Islamic Logo
                IslamicLogoWidget(),

                SizedBox(height: 6.h),

                // Welcome Text
                Text(
                  'Welcome Back',
                  style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),

                SizedBox(height: 1.h),

                Text(
                  'Continue your spiritual journey',
                  style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                  ),
                ),

                SizedBox(height: 4.h),

                // Login Form
                LoginFormWidget(),
                SizedBox(height: 4.h),

                // Divider with "OR"
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.dividerColor,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'OR',
                        style: AppTheme.lightTheme.textTheme.bodySmall
                            ?.copyWith(
                              color: AppTheme
                                  .lightTheme
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppTheme.lightTheme.dividerColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 3.h),

                // Social Login Options
                // SocialLoginWidget(
                //   onGoogleLogin: () => _handleSocialLogin('Google'),
                //   onAppleLogin: () => _handleSocialLogin('Apple'),
                // ),
                SizedBox(height: 6.h),

                // Registration Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'New user? ',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    GestureDetector(
                      onTap: _navigateToRegistration,
                      child: Text(
                        'Join our Ummah',
                        style: AppTheme.lightTheme.textTheme.bodyMedium
                            ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 2.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
