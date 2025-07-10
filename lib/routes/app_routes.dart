import 'package:dhikr_share/presentation/sign_up_screen/sign_up_screen.dart';
import 'package:dhikr_share/presentation/bottomNavBar/bottomNavBar.dart';
import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/islamic_onboarding/islamic_onboarding.dart';
import '../presentation/friends_list/friends_list.dart';
import '../presentation/main_dhikr_counter/main_dhikr_counter.dart';
import '../presentation/analytics_dashboard/analytics_dashboard.dart';
import '../presentation/settings/settings.dart';
import '../presentation/voice_recognition_session/voice_recognition_session.dart';
import '../presentation/ai_insights/ai_insights.dart';
import '../presentation/challenge_mode/challenge_mode.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splashScreen = '/splash-screen';
  static const String loginScreen = '/login-screen';
  static const String islamicOnboarding = '/islamic-onboarding';
  static const String friendsList = '/friends-list';
  static const String mainDhikrCounter = '/main-dhikr-counter';
  static const String analyticsDashboard = '/analytics-dashboard';
  static const String settings = '/settings';
  static const String voiceRecognitionSession = '/voice-recognition-session';
  static const String aiInsights = '/ai-insights';
  static const String challengeMode = '/challenge-mode';
  static const String signUpScreen = '/sign-up-screen';
  static const String bottomNav = '/bottom-nav';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splashScreen: (context) => const SplashScreen(),
    loginScreen: (context) => const LoginScreen(),
    islamicOnboarding: (context) => const IslamicOnboarding(),
    friendsList: (context) => const FriendsList(),
    mainDhikrCounter: (context) => const MainDhikrCounter(),
    analyticsDashboard: (context) => const AnalyticsDashboard(),
    settings: (context) => const Settings(),
    voiceRecognitionSession: (context) => const VoiceRecognitionSession(),
    aiInsights: (context) => const AiInsights(),
    challengeMode: (context) => const ChallengeMode(),
    signUpScreen: (context) => const SignUpScreen(),
    
    bottomNav: (context) => const BottomNavScreen(),
    // TODO: Add your other routes here
  };
}
