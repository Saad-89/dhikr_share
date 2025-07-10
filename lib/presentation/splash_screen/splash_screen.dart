import 'dart:developer';
import 'dart:math' as dart_math;

import 'package:dhikr_share/presentation/bottomNavBar/bottomNavBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _loadingAnimationController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _loadingAnimation;

  final bool _isLoading = true;
  String _loadingText = 'Initializing Islamic services...';
  double _loadingProgress = 0.0;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startSplashSequence();
  }

  void _initializeAnimations() {
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoAnimationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _logoAnimationController.forward();
  }

  Future<void> _startSplashSequence() async {
    try {
      await _performInitializationTasks();

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {}
  }

  Future<void> _performInitializationTasks() async {
    final tasks = [
      {'text': 'Connecting to Supabase...', 'duration': 800},
      {'text': 'Checking authentication...', 'duration': 600},
      {'text': 'Setting up voice recognition...', 'duration': 500},
      {'text': 'Preparing Dhikr counter...', 'duration': 700},
    ];

    _loadingAnimationController.forward();

    for (int i = 0; i < tasks.length; i++) {
      if (mounted) {
        setState(() {
          _loadingText = tasks[i]['text'] as String;
          _loadingProgress = (i + 1) / tasks.length;
        });
      }

      await Future.delayed(Duration(milliseconds: tasks[i]['duration'] as int));
    }

    // Final delay for smooth transition
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToNextScreen() async {
    final user = FirebaseAuth.instance.currentUser;
    log("email ${user?.email}");

    if (user != null) {
      print("User exists");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: AppRoutes.bottomNav),
          builder: (_) => const BottomNavScreen(),
        ),
        (route) => false,
      );

      return;
    }

    Navigator.pushNamed(context, '/islamic-onboarding');
  }

  void _retryInitialization() {
    setState(() {
      _hasError = false;
      _loadingProgress = 0.0;
      _loadingText = 'Initializing Islamic services...';
    });

    _loadingAnimationController.reset();
    _startSplashSequence();
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _loadingAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: AppTheme.lightTheme.primaryColor,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.lightTheme.primaryColor,
                AppTheme.lightTheme.primaryColor.withValues(alpha: 0.8),
                AppTheme.lightTheme.colorScheme.primaryContainer,
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(flex: 3, child: _buildLogoSection()),
                Expanded(flex: 1, child: _buildLoadingSection()),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Center(
      child: AnimatedBuilder(
        animation: _logoAnimationController,
        builder: (context, child) {
          return Opacity(
            opacity: _logoFadeAnimation.value,
            child: Transform.scale(
              scale: _logoScaleAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAppLogo(),
                  SizedBox(height: 3.h),
                  _buildAppTitle(),
                  SizedBox(height: 1.h),
                  _buildAppSubtitle(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppLogo() {
    return Container(
      width: 25.w,
      height: 25.w,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Islamic geometric pattern background
          CustomPaint(size: Size(20.w, 20.w), painter: IslamicPatternPainter()),
          // Main logo icon
          CustomIconWidget(iconName: 'mosque', color: Colors.white, size: 12.w),
        ],
      ),
    );
  }

  Widget _buildAppTitle() {
    return Text(
      'Dhikr Share',
      style: AppTheme.lightTheme.textTheme.headlineMedium?.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAppSubtitle() {
    return Text(
      'Remember Allah Together',
      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.9),
        letterSpacing: 0.8,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoadingSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLoadingIndicator(),
          SizedBox(height: 2.h),
          _buildLoadingText(),
          if (_hasError) ...[SizedBox(height: 2.h), _buildRetryButton()],
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return _hasError
        ? CustomIconWidget(
          iconName: 'error_outline',
          color: Colors.white.withValues(alpha: 0.8),
          size: 6.w,
        )
        : Column(
          children: [
            SizedBox(
              width: 6.w,
              height: 6.w,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withValues(alpha: 0.8),
                ),
                strokeWidth: 2.0,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              width: 60.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: AnimatedBuilder(
                animation: _loadingAnimation,
                builder: (context, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _loadingProgress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
  }

  Widget _buildLoadingText() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Text(
        _loadingText,
        key: ValueKey(_loadingText),
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: Colors.white.withValues(alpha: 0.8),
          fontSize: 12.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: _retryInitialization,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'refresh',
              color: Colors.white,
              size: 4.w,
            ),
            SizedBox(width: 2.w),
            Text(
              'Retry',
              style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for Islamic geometric patterns
class IslamicPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.1)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;

    // Draw Islamic star pattern
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * (3.14159 / 180);
      final startX = center.dx + radius * 0.5 * cos(angle);
      final startY = center.dy + radius * 0.5 * sin(angle);
      final endX = center.dx + radius * cos(angle);
      final endY = center.dy + radius * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }

    // Draw concentric circles
    canvas.drawCircle(center, radius * 0.3, paint);
    canvas.drawCircle(center, radius * 0.6, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper function for cos calculation
double cos(double radians) {
  return radians.cos();
}

// Helper function for sin calculation
double sin(double radians) {
  return radians.sin();
}

// Extension for trigonometric functions
extension TrigonometricFunctions on double {
  double cos() {
    return dart_math.cos(this);
  }

  double sin() {
    return dart_math.sin(this);
  }
}
