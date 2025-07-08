import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class EnhancedDhikrCounterWidget extends StatefulWidget {
  final int count;
  final bool useArabicNumerals;
  final Map<String, dynamic> selectedPhrase;
  final bool isVoiceListening;
  final double voiceVolume;
  final bool visualFeedbackEnabled;
  final bool hapticFeedbackEnabled;
  final VoidCallback? onPhraseDetected;

  const EnhancedDhikrCounterWidget({
    super.key,
    required this.count,
    this.useArabicNumerals = false,
    required this.selectedPhrase,
    this.isVoiceListening = false,
    this.voiceVolume = 0.0,
    this.visualFeedbackEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.onPhraseDetected,
  });

  @override
  State<EnhancedDhikrCounterWidget> createState() =>
      _EnhancedDhikrCounterWidgetState();
}

class _EnhancedDhikrCounterWidgetState extends State<EnhancedDhikrCounterWidget>
    with TickerProviderStateMixin {
  late AnimationController _incrementAnimationController;
  late AnimationController _listeningAnimationController;
  late AnimationController _volumeAnimationController;
  late AnimationController _successAnimationController;

  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _listeningPulseAnimation;
  late Animation<double> _volumeAnimation;
  late Animation<double> _successAnimation;

  int _lastCount = 0;
  bool _wasListening = false;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.count;
    _wasListening = widget.isVoiceListening;

    _incrementAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _listeningAnimationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    _volumeAnimationController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _incrementAnimationController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.primary,
      end: AppTheme.lightTheme.colorScheme.secondary,
    ).animate(CurvedAnimation(
      parent: _incrementAnimationController,
      curve: Curves.easeInOut,
    ));

    _listeningPulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _listeningAnimationController,
      curve: Curves.easeInOut,
    ));

    _volumeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _volumeAnimationController,
      curve: Curves.easeOut,
    ));

    _successAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _successAnimationController,
      curve: Curves.bounceOut,
    ));

    if (widget.isVoiceListening) {
      _listeningAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EnhancedDhikrCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle count changes with enhanced feedback
    if (oldWidget.count != widget.count) {
      debugPrint('=== ENHANCED COUNTER WIDGET UPDATE ===');
      debugPrint('Counter updated from ${oldWidget.count} to ${widget.count}');

      // Trigger increment animation
      _incrementAnimationController.forward().then((_) {
        _incrementAnimationController.reverse();
      });

      // Trigger success animation for voice detection
      if (widget.isVoiceListening && widget.onPhraseDetected != null) {
        _triggerSuccessAnimation();
      }

      _lastCount = widget.count;
    }

    // Handle listening state changes
    if (oldWidget.isVoiceListening != widget.isVoiceListening) {
      if (widget.isVoiceListening) {
        _listeningAnimationController.repeat(reverse: true);
      } else {
        _listeningAnimationController.stop();
        _listeningAnimationController.reset();
      }
      _wasListening = widget.isVoiceListening;
    }

    // Handle volume changes for sound sensitivity
    if (oldWidget.voiceVolume != widget.voiceVolume &&
        widget.isVoiceListening) {
      if (widget.voiceVolume > 0.3) {
        _volumeAnimationController.forward();
      } else {
        _volumeAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _incrementAnimationController.dispose();
    _listeningAnimationController.dispose();
    _volumeAnimationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _triggerSuccessAnimation() {
    if (!mounted) return;

    // Haptic feedback if enabled
    if (widget.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }

    // Visual feedback if enabled
    if (widget.visualFeedbackEnabled) {
      _successAnimationController.forward().then((_) {
        if (mounted) {
          _successAnimationController.reverse();
        }
      });
    }
  }

  String _formatNumber(int number) {
    return widget.useArabicNumerals
        ? _convertToArabicNumerals(number.toString())
        : number.toString();
  }

  String _convertToArabicNumerals(String number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.split('').map((digit) {
      final index = int.tryParse(digit);
      return index != null ? arabicNumerals[index] : digit;
    }).join();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _incrementAnimationController,
        _listeningAnimationController,
        _volumeAnimationController,
        _successAnimationController,
      ]),
      builder: (context, child) {
        final baseScale = _scaleAnimation.value;
        final listeningScale =
            widget.isVoiceListening ? _listeningPulseAnimation.value : 1.0;
        final volumeScale = widget.isVoiceListening
            ? (1.0 + (_volumeAnimation.value * widget.voiceVolume * 0.1))
            : 1.0;
        final finalScale = baseScale * listeningScale * volumeScale;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Listening outer rings (sound sensitivity indicator)
            if (widget.isVoiceListening && widget.visualFeedbackEnabled)
              ...List.generate(3, (index) {
                final ringScale = 1.0 +
                    (index + 1) * 0.15 +
                    (_volumeAnimation.value * widget.voiceVolume * 0.2);
                final opacity = (1.0 - (index * 0.3)) *
                    (0.3 + _volumeAnimation.value * widget.voiceVolume * 0.7);

                return Transform.scale(
                  scale: ringScale,
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: opacity),
                        width: 2,
                      ),
                    ),
                  ),
                );
              }),

            // Success indicator overlay
            if (_successAnimation.value > 0.0 && widget.visualFeedbackEnabled)
              Transform.scale(
                scale: 1.0 + (_successAnimation.value * 0.3),
                child: Container(
                  width: 65.w,
                  height: 65.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.green
                          .withValues(alpha: _successAnimation.value * 0.8),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 20.w,
                      color: Colors.green
                          .withValues(alpha: _successAnimation.value),
                    ),
                  ),
                ),
              ),

            // Main counter circle
            Transform.scale(
              scale: finalScale,
              child: Container(
                width: 60.w,
                height: 60.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isVoiceListening && widget.visualFeedbackEnabled
                      ? Color.lerp(_colorAnimation.value,
                          AppTheme.lightTheme.colorScheme.primary, 0.8)
                      : _colorAnimation.value,
                  boxShadow: [
                    BoxShadow(
                      color: widget.isVoiceListening
                          ? AppTheme.lightTheme.colorScheme.primary
                              .withValues(alpha: 0.4)
                          : AppTheme.lightTheme.colorScheme.shadow
                              .withValues(alpha: 0.3),
                      blurRadius: widget.isVoiceListening ? 20 : 15,
                      offset: Offset(0, 8),
                      spreadRadius: widget.isVoiceListening ? 2 : 0,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Counter Display
                    Text(
                      _formatNumber(widget.count),
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),

                    // Progress percentage display - restored feature
                    if (widget.selectedPhrase.isNotEmpty) ...[
                      SizedBox(height: 0.5.h),
                      Builder(
                        builder: (context) {
                          final dailyGoal =
                              widget.selectedPhrase['dailyGoal'] as int? ?? 33;
                          final percentage = dailyGoal > 0
                              ? ((widget.count / dailyGoal) * 100)
                                  .clamp(0.0, 100.0)
                                  .toInt()
                              : 0;

                          return Text(
                            '$percentage%',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],

                    SizedBox(height: 1.h),

                    // Current phrase indicator
                    if (widget.selectedPhrase.isNotEmpty)
                      Text(
                        widget.selectedPhrase['transliteration'] ?? '',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          color: Colors.white.withValues(alpha: 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    // Voice listening indicator
                    if (widget.isVoiceListening &&
                        widget.visualFeedbackEnabled) ...[
                      SizedBox(height: 0.5.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.mic,
                            size: 12.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            'Listening',
                            style: GoogleFonts.inter(
                              fontSize: 8.sp,
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
