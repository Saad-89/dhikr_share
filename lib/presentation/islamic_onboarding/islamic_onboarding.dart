import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/location_service.dart';
import '../../services/prayer_time_service.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class IslamicOnboarding extends StatefulWidget {
  const IslamicOnboarding({super.key});

  @override
  State<IslamicOnboarding> createState() => _IslamicOnboardingState();
}

class _IslamicOnboardingState extends State<IslamicOnboarding> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isSettingUpLocation = false;

  final List<Map<String, dynamic>> _onboardingData = [
    {
      "id": 1,
      "title": "Begin Your Spiritual Journey",
      "subtitle": "Track your daily Dhikr with sincere intention",
      "description":
          "Start your path of remembrance with our digital counter. Count SubhanAllah, Alhamdulillah, and Allahu Akbar with mindful presence.",
      "arabicText": "سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَاللَّهُ أَكْبَرُ",
      "arabicTranslation":
          "Glory be to Allah, praise be to Allah, and Allah is the Greatest",
      "hadithQuote":
          "\"Whoever says SubhanAllah wa bihamdihi 100 times, his sins are forgiven even if they are like the foam of the sea.\" - Sahih Bukhari",
      "imageUrl":
          "https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "primaryColor": AppTheme.primaryLight,
      "accentColor": AppTheme.accentLight,
    },
    {
      "id": 2,
      "title": "Voice Recognition Technology",
      "subtitle": "Speak your Dhikr, we'll detect and count automatically",
      "description":
          "Our advanced voice recognition detects different Dhikr phrases automatically. Simply speak any Dhikr and we'll identify and count it for you.",
      "arabicText": "لَا إِلَٰهَ إِلَّا اللَّهُ",
      "arabicTranslation": "There is no god but Allah",
      "hadithQuote":
          "\"The best remembrance is La ilaha illa Allah.\" - Sunan At-Tirmidhi",
      "imageUrl":
          "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "primaryColor": AppTheme.secondaryLight,
      "accentColor": AppTheme.accentLight,
    },
    {
      "id": 3,
      "title": "Connect with Fellow Muslims",
      "subtitle": "Share your spiritual progress with friends",
      "description":
          "Join a community of believers. Share your daily Dhikr counts, send encouragement, and motivate each other in remembrance of Allah.",
      "arabicText": "وَذَكِّرْ فَإِنَّ الذِّكْرَىٰ تَنفَعُ الْمُؤْمِنِينَ",
      "arabicTranslation":
          "And remind, for indeed, the reminder benefits the believers",
      "hadithQuote":
          "\"The believer is not one who eats his fill while his neighbor goes hungry.\" - Al-Adab Al-Mufrad",
      "imageUrl":
          "https://images.unsplash.com/photo-1542816417-0983c9c9ad53?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "primaryColor": AppTheme.successLight,
      "accentColor": AppTheme.accentLight,
    },
    {
      "id": 4,
      "title": "AI-Powered Spiritual Insights",
      "subtitle": "Personalized guidance for your spiritual growth",
      "description":
          "Receive intelligent insights about your Dhikr patterns, personalized reminders aligned with prayer times, and suggestions for spiritual improvement.",
      "arabicText": "وَاذْكُرُوا اللَّهَ كَثِيرًا لَّعَلَّكُمْ تُفْلِحُونَ",
      "arabicTranslation": "And remember Allah often that you may succeed",
      "hadithQuote":
          "\"Remember often the destroyer of pleasures: death.\" - Sunan At-Tirmidhi",
      "imageUrl":
          "https://images.unsplash.com/photo-1609599006353-e629aaabfeae?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "primaryColor": AppTheme.warningLight,
      "accentColor": AppTheme.accentLight,
    },
    {
      "id": 5,
      "title": "Location-Based Prayer Times",
      "subtitle": "Get accurate prayer times for your location",
      "description":
          "Allow location access to receive precise prayer times based on your geographical location. This helps align your Dhikr reminders with Salah schedule.",
      "arabicText": "وَأَقِيمُوا الصَّلَاةَ وَآتُوا الزَّكَاةَ",
      "arabicTranslation": "And establish prayer and give zakah",
      "hadithQuote": "\"Prayer is the pillar of religion.\" - Sahih Al-Bukhari",
      "imageUrl":
          "https://images.unsplash.com/photo-1596125160970-6f02eeba00d3?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "primaryColor": AppTheme.primaryLight,
      "accentColor": AppTheme.accentLight,
      "isPermissionPage": true,
    },
  ];

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    Navigator.pushReplacementNamed(context, '/login-screen');
  }

  void _requestLocationPermission() async {
    setState(() {
      _isSettingUpLocation = true;
    });

    try {
      final locationInfo = await LocationService.getLocationInfo();

      if (locationInfo != null) {
        // Save location info to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setDouble('user_latitude', locationInfo['latitude']);
        await prefs.setDouble('user_longitude', locationInfo['longitude']);
        await prefs.setString('user_city', locationInfo['city']);
        await prefs.setBool('location_permission_granted', true);

        // Calculate and save prayer times
        final prayerTimes = await PrayerTimeService.calculatePrayerTimes(
          locationInfo['latitude'],
          locationInfo['longitude'],
          DateTime.now(),
        );

        // Save prayer times (as timestamp strings)
        for (final entry in prayerTimes.entries) {
          await prefs.setString(
            'prayer_${entry.key}',
            entry.value.toIso8601String(),
          );
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location set successfully! Prayer times for ${locationInfo['city']} are now available.',
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          ),
        );
      } else {
        // Handle permission denied
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location permission denied. You can set this up later in settings.',
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.error,
          ),
        );
      }
    } catch (e) {
      print('Error setting up location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to set up location. You can try again later in settings.',
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    } finally {
      setState(() {
        _isSettingUpLocation = false;
      });

      // Wait a bit to show the snackbar, then complete onboarding
      await Future.delayed(Duration(seconds: 2));
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Main PageView
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final pageData = _onboardingData[index];
                return OnboardingPageWidget(
                  title: pageData["title"] as String,
                  subtitle: pageData["subtitle"] as String,
                  description: pageData["description"] as String,
                  arabicText: pageData["arabicText"] as String,
                  arabicTranslation: pageData["arabicTranslation"] as String,
                  hadithQuote: pageData["hadithQuote"] as String,
                  imageUrl: pageData["imageUrl"] as String,
                  primaryColor: pageData["primaryColor"] as Color,
                  accentColor: pageData["accentColor"] as Color,
                  isPermissionPage:
                      pageData["isPermissionPage"] as bool? ?? false,
                  onPermissionRequest: _requestLocationPermission,
                );
              },
            ),


            // Top Page Indicator
            Positioned(
              top: 2.h,
              left: 0,
              right: 0,
              child: PageIndicatorWidget(
                currentPage: _currentPage,
                totalPages: _onboardingData.length,
              ),
            ),

            // Bottom Navigation Controls
        SizedBox(height: 10.h),
            
            Positioned(
              bottom: 4.h,
              left: 6.w,
              right: 6.w,
              child: _buildBottomControls(),
            ),

            // Skip Button (Top Right)
            if (_currentPage < _onboardingData.length - 1)
              Positioned(
                top: 2.h,
                right: 6.w,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                  ),
                  child: Text(
                    'Skip',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
   
    );
  }

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _onboardingData.length - 1;
    final isPermissionPage =
        _onboardingData[_currentPage]["isPermissionPage"] as bool? ?? false;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
       
        SizedBox(
          width: double.infinity,
          height: 6.h,
          child: ElevatedButton(
            onPressed: _isSettingUpLocation
                ? null
                : isPermissionPage
                ? _requestLocationPermission
                : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _onboardingData[_currentPage]["primaryColor"] as Color,
              foregroundColor: Colors.white,
              elevation: 3,
              shadowColor:
                  (_onboardingData[_currentPage]["primaryColor"] as Color)
                      .withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isSettingUpLocation
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Setting up location...',
                        style: AppTheme.lightTheme.textTheme.labelLarge
                            ?.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isPermissionPage
                            ? 'Allow Location Access'
                            : isLastPage
                            ? 'Start Your Journey'
                            : 'Continue',
                        style: AppTheme.lightTheme.textTheme.labelLarge
                            ?.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(width: 2.w),
                      CustomIconWidget(
                        iconName: isPermissionPage
                            ? 'location_on'
                            : isLastPage
                            ? 'mosque'
                            : 'arrow_forward',
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
          ),
        ),

        // Secondary Action (Back button for non-first pages)
        if (_currentPage > 0) ...[
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            height: 5.h,
            child: OutlinedButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    _onboardingData[_currentPage]["primaryColor"] as Color,
                side: BorderSide(
                  color: _onboardingData[_currentPage]["primaryColor"] as Color,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'arrow_back',
                    color:
                        _onboardingData[_currentPage]["primaryColor"] as Color,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Previous',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      fontSize: 14.sp,
                      color: _onboardingData[_currentPage]["primaryColor"]
                          as Color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
