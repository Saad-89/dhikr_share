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

  static const double _maxIncrementScale = 1.05;
  static const double _maxListeningScale = 1.02;
  static const double _maxVolumeScale = 0.03;
  static const double _maxSuccessScale = 0.1;
  static const double _maxRingScale = 0.015; // Reduced from 0.05

  @override
  void initState() {
    super.initState();
    _lastCount = widget.count;
    _wasListening = widget.isVoiceListening;

    _incrementAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _listeningAnimationController = AnimationController(
      duration: Duration(milliseconds: 3000),
      vsync: this,
    );

    _volumeAnimationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _successAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _maxIncrementScale,
    ).animate(
      CurvedAnimation(
        parent: _incrementAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _colorAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.primary,
      end: AppTheme.lightTheme.colorScheme.secondary,
    ).animate(
      CurvedAnimation(
        parent: _incrementAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _listeningPulseAnimation = Tween<double>(
      begin: 1.0,
      end: _maxListeningScale,
    ).animate(
      CurvedAnimation(
        parent: _listeningAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _volumeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _volumeAnimationController,
        curve: Curves.easeOut,
      ),
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successAnimationController,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isVoiceListening) {
      _listeningAnimationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(EnhancedDhikrCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.count != widget.count) {
      _incrementAnimationController.forward().then((_) {
        _incrementAnimationController.reverse();
      });

      if (widget.isVoiceListening && widget.onPhraseDetected != null) {
        _triggerSuccessAnimation();
      }

      _lastCount = widget.count;
    }

    if (oldWidget.isVoiceListening != widget.isVoiceListening) {
      if (widget.isVoiceListening) {
        _listeningAnimationController.repeat(reverse: true);
      } else {
        _listeningAnimationController.stop();
        _listeningAnimationController.reset();
      }
      _wasListening = widget.isVoiceListening;
    }

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

    if (widget.hapticFeedbackEnabled) {
      HapticFeedback.mediumImpact();
    }

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
        final volumeScale =
            widget.isVoiceListening
                ? (1.0 +
                    (_volumeAnimation.value *
                        widget.voiceVolume *
                        _maxVolumeScale))
                : 1.0;
        final finalScale = baseScale * listeningScale * volumeScale;

        return Container(
          width: 65.w,
          height: 65.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Reduced listening outer ring
              if (widget.isVoiceListening && widget.visualFeedbackEnabled)
                ...List.generate(1, (index) {
                  final ringScale =
                      1.0 +
                      (index + 1) * _maxRingScale +
                      (_volumeAnimation.value *
                          widget.voiceVolume *
                          _maxRingScale);

                  final opacity =
                      (1.0 - (index * 0.4)) *
                      (0.1 +
                          _volumeAnimation.value *
                              widget.voiceVolume *
                              0.15); // Lower opacity

                  return Container(
                    width: 60.w,
                    height: 60.w,
                    child: Transform.scale(
                      scale: ringScale,
                      child: Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withOpacity(opacity.clamp(0.0, 1.0)),
                            width: 0.5, // Reduced thickness
                          ),
                        ),
                      ),
                    ),
                  );
                }),

              // Success visual
              if (_successAnimation.value > 0.0 && widget.visualFeedbackEnabled)
                Container(
                  width: 60.w,
                  height: 60.w,
                  child: Transform.scale(
                    scale: 1.0 + (_successAnimation.value * _maxSuccessScale),
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withOpacity(
                            (_successAnimation.value * 0.6).clamp(0.0, 1.0),
                          ),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check_circle,
                          size: 15.w,
                          color: Colors.green.withOpacity(
                            (_successAnimation.value * 0.8).clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // Main counter
              Transform.scale(
                scale: finalScale.clamp(0.95, 1.08),
                child: Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        widget.isVoiceListening && widget.visualFeedbackEnabled
                            ? Color.lerp(
                              _colorAnimation.value,
                              AppTheme.lightTheme.colorScheme.primary,
                              0.8,
                            )
                            : _colorAnimation.value,
                    boxShadow: [
                      BoxShadow(
                        color:
                            widget.isVoiceListening
                                ? AppTheme.lightTheme.colorScheme.primary
                                    .withOpacity(0.3)
                                : AppTheme.lightTheme.colorScheme.shadow
                                    .withOpacity(0.2),
                        blurRadius: widget.isVoiceListening ? 12 : 8,
                        offset: Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _formatNumber(widget.count),
                        style: GoogleFonts.inter(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (widget.selectedPhrase.isNotEmpty) ...[
                        SizedBox(height: 0.5.h),
                        Builder(
                          builder: (context) {
                            final dailyGoal =
                                widget.selectedPhrase['dailyGoal'] as int? ??
                                33;
                            final percentage =
                                dailyGoal > 0
                                    ? ((widget.count / dailyGoal) * 100)
                                        .clamp(0.0, 100.0)
                                        .toInt()
                                    : 0;

                            return Text(
                              '$percentage%',
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ],
                      SizedBox(height: 1.h),
                      if (widget.selectedPhrase.isNotEmpty)
                        Text(
                          widget.selectedPhrase['transliteration'] ?? '',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
                              color: Colors.white.withOpacity(0.8),
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              'Listening',
                              style: GoogleFonts.inter(
                                fontSize: 8.sp,
                                color: Colors.white.withOpacity(0.8),
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
          ),
        );
      },
    );
  }
}



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../../core/app_export.dart';
// import '../../../theme/app_theme.dart';

// class EnhancedDhikrCounterWidget extends StatefulWidget {
//   final int count;
//   final bool useArabicNumerals;
//   final Map<String, dynamic> selectedPhrase;
//   final bool isVoiceListening;
//   final double voiceVolume;
//   final bool visualFeedbackEnabled;
//   final bool hapticFeedbackEnabled;
//   final VoidCallback? onPhraseDetected;

//   const EnhancedDhikrCounterWidget({
//     super.key,
//     required this.count,
//     this.useArabicNumerals = false,
//     required this.selectedPhrase,
//     this.isVoiceListening = false,
//     this.voiceVolume = 0.0,
//     this.visualFeedbackEnabled = true,
//     this.hapticFeedbackEnabled = true,
//     this.onPhraseDetected,
//   });

//   @override
//   State<EnhancedDhikrCounterWidget> createState() =>
//       _EnhancedDhikrCounterWidgetState();
// }

// class _EnhancedDhikrCounterWidgetState extends State<EnhancedDhikrCounterWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _incrementAnimationController;
//   late AnimationController _listeningAnimationController;
//   late AnimationController _volumeAnimationController;
//   late AnimationController _successAnimationController;

//   late Animation<double> _scaleAnimation;
//   late Animation<Color?> _colorAnimation;
//   late Animation<double> _listeningPulseAnimation;
//   late Animation<double> _volumeAnimation;
//   late Animation<double> _successAnimation;

//   int _lastCount = 0;
//   bool _wasListening = false;

//   // Animation constraints to prevent excessive scaling
//   static const double _maxIncrementScale = 0.05; // Reduced from 1.15
//   static const double _maxListeningScale = 0.2; // Reduced from 1.08
//   static const double _maxVolumeScale = 0.01; // Reduced from 0.1
//   static const double _maxSuccessScale = 0.1; // Reduced from 0.3
//   static const double _maxRingScale = 0.03; // New constraint for rings

//   @override
//   void initState() {
//     super.initState();
//     _lastCount = widget.count;
//     _wasListening = widget.isVoiceListening;

//     _incrementAnimationController = AnimationController(
//       duration: Duration(milliseconds: 200), // Faster animation
//       vsync: this,
//     );

//     _listeningAnimationController = AnimationController(
//       duration: Duration(milliseconds: 3000), // Slower for smoothness
//       vsync: this,
//     );

//     _volumeAnimationController = AnimationController(
//       duration: Duration(milliseconds: 150), // Slightly slower
//       vsync: this,
//     );

//     _successAnimationController = AnimationController(
//       duration: Duration(milliseconds: 400), // Faster success animation
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(
//       begin: 1.0,
//       end: _maxIncrementScale,
//     ).animate(
//       CurvedAnimation(
//         parent: _incrementAnimationController,
//         curve: Curves.easeOut, // Smoother curve
//       ),
//     );

//     _colorAnimation = ColorTween(
//       begin: AppTheme.lightTheme.colorScheme.primary,
//       end: AppTheme.lightTheme.colorScheme.secondary,
//     ).animate(
//       CurvedAnimation(
//         parent: _incrementAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _listeningPulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: _maxListeningScale,
//     ).animate(
//       CurvedAnimation(
//         parent: _listeningAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _volumeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _volumeAnimationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _successAnimationController,
//         curve: Curves.easeOut, // Smoother success animation
//       ),
//     );

//     if (widget.isVoiceListening) {
//       _listeningAnimationController.repeat(reverse: true);
//     }
//   }

//   @override
//   void didUpdateWidget(EnhancedDhikrCounterWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // Handle count changes with enhanced feedback
//     if (oldWidget.count != widget.count) {
//       debugPrint('=== ENHANCED COUNTER WIDGET UPDATE ===');
//       debugPrint('Counter updated from ${oldWidget.count} to ${widget.count}');

//       // Trigger increment animation
//       _incrementAnimationController.forward().then((_) {
//         _incrementAnimationController.reverse();
//       });

//       // Trigger success animation for voice detection
//       if (widget.isVoiceListening && widget.onPhraseDetected != null) {
//         _triggerSuccessAnimation();
//       }

//       _lastCount = widget.count;
//     }

//     // Handle listening state changes
//     if (oldWidget.isVoiceListening != widget.isVoiceListening) {
//       if (widget.isVoiceListening) {
//         _listeningAnimationController.repeat(reverse: true);
//       } else {
//         _listeningAnimationController.stop();
//         _listeningAnimationController.reset();
//       }
//       _wasListening = widget.isVoiceListening;
//     }

//     // Handle volume changes for sound sensitivity
//     if (oldWidget.voiceVolume != widget.voiceVolume &&
//         widget.isVoiceListening) {
//       if (widget.voiceVolume > 0.3) {
//         _volumeAnimationController.forward();
//       } else {
//         _volumeAnimationController.reverse();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _incrementAnimationController.dispose();
//     _listeningAnimationController.dispose();
//     _volumeAnimationController.dispose();
//     _successAnimationController.dispose();
//     super.dispose();
//   }

//   void _triggerSuccessAnimation() {
//     if (!mounted) return;

//     // Haptic feedback if enabled
//     if (widget.hapticFeedbackEnabled) {
//       HapticFeedback.mediumImpact();
//     }

//     // Visual feedback if enabled
//     if (widget.visualFeedbackEnabled) {
//       _successAnimationController.forward().then((_) {
//         if (mounted) {
//           _successAnimationController.reverse();
//         }
//       });
//     }
//   }

//   String _formatNumber(int number) {
//     return widget.useArabicNumerals
//         ? _convertToArabicNumerals(number.toString())
//         : number.toString();
//   }

//   String _convertToArabicNumerals(String number) {
//     const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
//     return number.split('').map((digit) {
//       final index = int.tryParse(digit);
//       return index != null ? arabicNumerals[index] : digit;
//     }).join();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _incrementAnimationController,
//         _listeningAnimationController,
//         _volumeAnimationController,
//         _successAnimationController,
//       ]),
//       builder: (context, child) {
//         final baseScale = _scaleAnimation.value;
//         final listeningScale =
//             widget.isVoiceListening ? _listeningPulseAnimation.value : 1.0;
//         final volumeScale =
//             widget.isVoiceListening
//                 ? (1.0 +
//                     (_volumeAnimation.value *
//                         widget.voiceVolume *
//                         _maxVolumeScale))
//                 : 1.0;
//         final finalScale = baseScale * listeningScale * volumeScale;

//         return Container(
//           // Fixed container to prevent overflow
//           width: 65.w,
//           height: 65.w,
//           child: Stack(
//             alignment: Alignment.center,
//             children: [
//               // Listening outer rings (sound sensitivity indicator) - much more controlled
//               if (widget.isVoiceListening && widget.visualFeedbackEnabled)
//                 ...List.generate(2, (index) {
//                   // Reduced from 3 to 2 rings
//                   final ringScale =
//                       1.0 +
//                       (index + 1) *
//                           _maxRingScale + // Much smaller ring expansion
//                       (_volumeAnimation.value *
//                           widget.voiceVolume *
//                           _maxRingScale);
//                   final opacity =
//                       (1.0 - (index * 0.4)) *
//                       (0.2 +
//                           _volumeAnimation.value *
//                               widget.voiceVolume *
//                               0.3); // Reduced opacity

//                   return Container(
//                     width: 60.w,
//                     height: 60.w,
//                     child: Transform.scale(
//                       scale: ringScale,
//                       child: Container(
//                         width: 60.w,
//                         height: 60.w,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           border: Border.all(
//                             color: AppTheme.lightTheme.colorScheme.primary
//                                 .withValues(alpha: opacity),
//                             width: 1, // Reduced border width
//                           ),
//                         ),
//                       ),
//                     ),
//                   );
//                 }),

//               // Success indicator overlay - more controlled
//               if (_successAnimation.value > 0.0 && widget.visualFeedbackEnabled)
//                 Container(
//                   width: 60.w,
//                   height: 60.w,
//                   child: Transform.scale(
//                     scale: 1.0 + (_successAnimation.value * _maxSuccessScale),
//                     child: Container(
//                       width: 60.w,
//                       height: 60.w,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: Colors.green.withValues(
//                             alpha: _successAnimation.value * 0.6,
//                           ),
//                           width: 2, // Reduced border width
//                         ),
//                       ),
//                       child: Center(
//                         child: Icon(
//                           Icons.check_circle,
//                           size: 15.w, // Reduced icon size
//                           color: Colors.green.withValues(
//                             alpha: _successAnimation.value * 0.8,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),

//               // Main counter circle - controlled scaling
//               Transform.scale(
//                 scale: finalScale.clamp(
//                   0.95,
//                   1.08,
//                 ), // Clamp to prevent excessive scaling
//                 child: Container(
//                   width: 60.w,
//                   height: 60.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     color:
//                         widget.isVoiceListening && widget.visualFeedbackEnabled
//                             ? Color.lerp(
//                               _colorAnimation.value,
//                               AppTheme.lightTheme.colorScheme.primary,
//                               0.8,
//                             )
//                             : _colorAnimation.value,
//                     boxShadow: [
//                       BoxShadow(
//                         color:
//                             widget.isVoiceListening
//                                 ? AppTheme.lightTheme.colorScheme.primary
//                                     .withValues(
//                                       alpha: 0.3, // Reduced shadow opacity
//                                     )
//                                 : AppTheme.lightTheme.colorScheme.shadow
//                                     .withValues(alpha: 0.2),
//                         blurRadius:
//                             widget.isVoiceListening ? 12 : 8, // Reduced blur
//                         offset: Offset(0, 4), // Reduced offset
//                         spreadRadius: 0, // No spread to prevent growth
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       // Counter Display
//                       Text(
//                         _formatNumber(widget.count),
//                         style: GoogleFonts.inter(
//                           fontSize: 26.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),

//                       // Progress percentage display - restored feature
//                       if (widget.selectedPhrase.isNotEmpty) ...[
//                         SizedBox(height: 0.5.h),
//                         Builder(
//                           builder: (context) {
//                             final dailyGoal =
//                                 widget.selectedPhrase['dailyGoal'] as int? ??
//                                 33;
//                             final percentage =
//                                 dailyGoal > 0
//                                     ? ((widget.count / dailyGoal) * 100)
//                                         .clamp(0.0, 100.0)
//                                         .toInt()
//                                     : 0;

//                             return Text(
//                               '$percentage%',
//                               style: GoogleFonts.inter(
//                                 fontSize: 16.sp,
//                                 color: Colors.white.withValues(alpha: 0.9),
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             );
//                           },
//                         ),
//                       ],

//                       SizedBox(height: 1.h),

//                       // Current phrase indicator
//                       if (widget.selectedPhrase.isNotEmpty)
//                         Text(
//                           widget.selectedPhrase['transliteration'] ?? '',
//                           style: GoogleFonts.inter(
//                             fontSize: 14.sp,
//                             color: Colors.white.withValues(alpha: 0.8),
//                             fontWeight: FontWeight.w500,
//                           ),
//                           textAlign: TextAlign.center,
//                         ),

//                       // Voice listening indicator
//                       if (widget.isVoiceListening &&
//                           widget.visualFeedbackEnabled) ...[
//                         SizedBox(height: 0.5.h),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(
//                               Icons.mic,
//                               size: 12.sp,
//                               color: Colors.white.withValues(alpha: 0.8),
//                             ),
//                             SizedBox(width: 1.w),
//                             Text(
//                               'Listening',
//                               style: GoogleFonts.inter(
//                                 fontSize: 8.sp,
//                                 color: Colors.white.withValues(alpha: 0.8),
//                                 fontWeight: FontWeight.w400,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';
// import 'package:google_fonts/google_fonts.dart';

// import '../../../core/app_export.dart';
// import '../../../theme/app_theme.dart';

// class EnhancedDhikrCounterWidget extends StatefulWidget {
//   final int count;
//   final bool useArabicNumerals;
//   final Map<String, dynamic> selectedPhrase;
//   final bool isVoiceListening;
//   final double voiceVolume;
//   final bool visualFeedbackEnabled;
//   final bool hapticFeedbackEnabled;
//   final VoidCallback? onPhraseDetected;

//   const EnhancedDhikrCounterWidget({
//     super.key,
//     required this.count,
//     this.useArabicNumerals = false,
//     required this.selectedPhrase,
//     this.isVoiceListening = false,
//     this.voiceVolume = 0.0,
//     this.visualFeedbackEnabled = true,
//     this.hapticFeedbackEnabled = true,
//     this.onPhraseDetected,
//   });

//   @override
//   State<EnhancedDhikrCounterWidget> createState() =>
//       _EnhancedDhikrCounterWidgetState();
// }

// class _EnhancedDhikrCounterWidgetState extends State<EnhancedDhikrCounterWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _incrementAnimationController;
//   late AnimationController _listeningAnimationController;
//   late AnimationController _volumeAnimationController;
//   late AnimationController _successAnimationController;

//   late Animation<double> _scaleAnimation;
//   late Animation<Color?> _colorAnimation;
//   late Animation<double> _listeningPulseAnimation;
//   late Animation<double> _volumeAnimation;
//   late Animation<double> _successAnimation;

//   int _lastCount = 0;
//   bool _wasListening = false;

//   @override
//   void initState() {
//     super.initState();
//     _lastCount = widget.count;
//     _wasListening = widget.isVoiceListening;

//     _incrementAnimationController = AnimationController(
//       duration: Duration(milliseconds: 300),
//       vsync: this,
//     );

//     _listeningAnimationController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _volumeAnimationController = AnimationController(
//       duration: Duration(milliseconds: 100),
//       vsync: this,
//     );

//     _successAnimationController = AnimationController(
//       duration: Duration(milliseconds: 600),
//       vsync: this,
//     );

//     _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
//       CurvedAnimation(
//         parent: _incrementAnimationController,
//         curve: Curves.elasticOut,
//       ),
//     );

//     _colorAnimation =
//         ColorTween(
//           begin: AppTheme.lightTheme.colorScheme.primary,
//           end: AppTheme.lightTheme.colorScheme.secondary,
//         ).animate(
//           CurvedAnimation(
//             parent: _incrementAnimationController,
//             curve: Curves.easeInOut,
//           ),
//         );

//     _listeningPulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
//       CurvedAnimation(
//         parent: _listeningAnimationController,
//         curve: Curves.easeInOut,
//       ),
//     );

//     _volumeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _volumeAnimationController,
//         curve: Curves.easeOut,
//       ),
//     );

//     _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _successAnimationController,
//         curve: Curves.bounceOut,
//       ),
//     );

//     if (widget.isVoiceListening) {
//       _listeningAnimationController.repeat(reverse: true);
//     }
//   }

//   @override
//   void didUpdateWidget(EnhancedDhikrCounterWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     // Handle count changes with enhanced feedback
//     if (oldWidget.count != widget.count) {
//       debugPrint('=== ENHANCED COUNTER WIDGET UPDATE ===');
//       debugPrint('Counter updated from ${oldWidget.count} to ${widget.count}');

//       // Trigger increment animation
//       _incrementAnimationController.forward().then((_) {
//         _incrementAnimationController.reverse();
//       });

//       // Trigger success animation for voice detection
//       if (widget.isVoiceListening && widget.onPhraseDetected != null) {
//         _triggerSuccessAnimation();
//       }

//       _lastCount = widget.count;
//     }

//     // Handle listening state changes
//     if (oldWidget.isVoiceListening != widget.isVoiceListening) {
//       if (widget.isVoiceListening) {
//         _listeningAnimationController.repeat(reverse: true);
//       } else {
//         _listeningAnimationController.stop();
//         _listeningAnimationController.reset();
//       }
//       _wasListening = widget.isVoiceListening;
//     }

//     // Handle volume changes for sound sensitivity
//     if (oldWidget.voiceVolume != widget.voiceVolume &&
//         widget.isVoiceListening) {
//       if (widget.voiceVolume > 0.3) {
//         _volumeAnimationController.forward();
//       } else {
//         _volumeAnimationController.reverse();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _incrementAnimationController.dispose();
//     _listeningAnimationController.dispose();
//     _volumeAnimationController.dispose();
//     _successAnimationController.dispose();
//     super.dispose();
//   }

//   void _triggerSuccessAnimation() {
//     if (!mounted) return;

//     // Haptic feedback if enabled
//     if (widget.hapticFeedbackEnabled) {
//       HapticFeedback.mediumImpact();
//     }

//     // Visual feedback if enabled
//     if (widget.visualFeedbackEnabled) {
//       _successAnimationController.forward().then((_) {
//         if (mounted) {
//           _successAnimationController.reverse();
//         }
//       });
//     }
//   }

//   String _formatNumber(int number) {
//     return widget.useArabicNumerals
//         ? _convertToArabicNumerals(number.toString())
//         : number.toString();
//   }

//   String _convertToArabicNumerals(String number) {
//     const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
//     return number.split('').map((digit) {
//       final index = int.tryParse(digit);
//       return index != null ? arabicNumerals[index] : digit;
//     }).join();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: Listenable.merge([
//         _incrementAnimationController,
//         _listeningAnimationController,
//         _volumeAnimationController,
//         _successAnimationController,
//       ]),
//       builder: (context, child) {
//         final baseScale = _scaleAnimation.value;
//         final listeningScale = widget.isVoiceListening
//             ? _listeningPulseAnimation.value
//             : 1.0;
//         final volumeScale = widget.isVoiceListening
//             ? (1.0 + (_volumeAnimation.value * widget.voiceVolume * 0.1))
//             : 1.0;
//         final finalScale = baseScale * listeningScale * volumeScale;

//         return Stack(
//           alignment: Alignment.center,
//           children: [
//             // Listening outer rings (sound sensitivity indicator)
//             if (widget.isVoiceListening && widget.visualFeedbackEnabled)
//               ...List.generate(3, (index) {
//                 final ringScale =
//                     1.0 +
//                     (index + 1) * 0.15 +
//                     (_volumeAnimation.value * widget.voiceVolume * 0.2);
//                 final opacity =
//                     (1.0 - (index * 0.3)) *
//                     (0.3 + _volumeAnimation.value * widget.voiceVolume * 0.7);

//                 return Transform.scale(
//                   scale: ringScale,
//                   child: Container(
//                     width: 60.w,
//                     height: 60.w,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: AppTheme.lightTheme.colorScheme.primary
//                             .withValues(alpha: opacity),
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                 );
//               }),

//             // Success indicator overlay
//             if (_successAnimation.value > 0.0 && widget.visualFeedbackEnabled)
//               Transform.scale(
//                 scale: 1.0 + (_successAnimation.value * 0.3),
//                 child: Container(
//                   width: 65.w,
//                   height: 65.w,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.green.withValues(
//                         alpha: _successAnimation.value * 0.8,
//                       ),
//                       width: 4,
//                     ),
//                   ),
//                   child: Center(
//                     child: Icon(
//                       Icons.check_circle,
//                       size: 20.w,
//                       color: Colors.green.withValues(
//                         alpha: _successAnimation.value,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),

//             // Main counter circle
//             Transform.scale(
//               scale: finalScale,
//               child: Container(
//                 width: 60.w,
//                 height: 60.w,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: widget.isVoiceListening && widget.visualFeedbackEnabled
//                       ? Color.lerp(
//                           _colorAnimation.value,
//                           AppTheme.lightTheme.colorScheme.primary,
//                           0.8,
//                         )
//                       : _colorAnimation.value,
//                   boxShadow: [
//                     BoxShadow(
//                       color: widget.isVoiceListening
//                           ? AppTheme.lightTheme.colorScheme.primary.withValues(
//                               alpha: 0.4,
//                             )
//                           : AppTheme.lightTheme.colorScheme.shadow.withValues(
//                               alpha: 0.3,
//                             ),
//                       blurRadius: widget.isVoiceListening ? 20 : 15,
//                       offset: Offset(0, 8),
//                       spreadRadius: widget.isVoiceListening ? 2 : 0,
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     // Counter Display
//                     Text(
//                       _formatNumber(widget.count),
//                       style: GoogleFonts.inter(
//                         fontSize: 26.sp,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),

//                     // Progress percentage display - restored feature
//                     if (widget.selectedPhrase.isNotEmpty) ...[
//                       SizedBox(height: 0.5.h),
//                       Builder(
//                         builder: (context) {
//                           final dailyGoal =
//                               widget.selectedPhrase['dailyGoal'] as int? ?? 33;
//                           final percentage = dailyGoal > 0
//                               ? ((widget.count / dailyGoal) * 100)
//                                     .clamp(0.0, 100.0)
//                                     .toInt()
//                               : 0;

//                           return Text(
//                             '$percentage%',
//                             style: GoogleFonts.inter(
//                               fontSize: 16.sp,
//                               color: Colors.white.withValues(alpha: 0.9),
//                               fontWeight: FontWeight.w600,
//                             ),
//                           );
//                         },
//                       ),
//                     ],

//                     SizedBox(height: 1.h),

//                     // Current phrase indicator
//                     if (widget.selectedPhrase.isNotEmpty)
//                       Text(
//                         widget.selectedPhrase['transliteration'] ?? '',
//                         style: GoogleFonts.inter(
//                           fontSize: 14.sp,
//                           color: Colors.white.withValues(alpha: 0.8),
//                           fontWeight: FontWeight.w500,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),

//                     // Voice listening indicator
//                     if (widget.isVoiceListening &&
//                         widget.visualFeedbackEnabled) ...[
//                       SizedBox(height: 0.5.h),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Icon(
//                             Icons.mic,
//                             size: 12.sp,
//                             color: Colors.white.withValues(alpha: 0.8),
//                           ),
//                           SizedBox(width: 1.w),
//                           Text(
//                             'Listening',
//                             style: GoogleFonts.inter(
//                               fontSize: 8.sp,
//                               color: Colors.white.withValues(alpha: 0.8),
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
