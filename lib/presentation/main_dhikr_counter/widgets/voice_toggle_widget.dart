import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/ai_speech_recognition_service.dart';

class VoiceToggleWidget extends StatefulWidget {
  final bool isActive;
  final bool isInitialized;
  final VoidCallback onToggle;
  final bool visualFeedbackEnabled;
  final bool hapticFeedbackEnabled;
  final String status;

  const VoiceToggleWidget({
    super.key,
    required this.isActive,
    required this.isInitialized,
    required this.onToggle,
    this.visualFeedbackEnabled = true,
    this.hapticFeedbackEnabled = true,
    this.status = 'Ready',
  });

  @override
  State<VoiceToggleWidget> createState() => _VoiceToggleWidgetState();
}

class _VoiceToggleWidgetState extends State<VoiceToggleWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breathingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _breathingAnimation;

  // Animation constraints - much more controlled
  static const double _maxPulseScale = 1.05; // Very minimal pulse
  static const double _maxBreathingScale = 1.01; // Very subtle breathing
  static const double _minBreathingScale = 0.99; // Very subtle breathing
  static const int _pulseDuration = 2000; // Slower pulse
  static const int _breathingDuration = 4000; // Much slower breathing

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(milliseconds: _pulseDuration),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: Duration(milliseconds: _breathingDuration),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: _maxPulseScale).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _breathingAnimation = Tween<double>(
      begin: _minBreathingScale,
      end: _maxBreathingScale,
    ).animate(
      CurvedAnimation(parent: _breathingController, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _startAnimations();
    }
  }

  @override
  void didUpdateWidget(VoiceToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _breathingController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _pulseController.stop();
    _breathingController.stop();
    _pulseController.reset();
    _breathingController.reset();
  }

  void _handleToggle() {
    if (widget.hapticFeedbackEnabled) {
      HapticFeedback.lightImpact();
    }
    widget.onToggle();
  }

  Color get _statusColor {
    if (!widget.isInitialized) return Colors.grey;
    if (widget.isActive) return AppTheme.lightTheme.colorScheme.primary;
    return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
  }

  String get _statusText {
    if (AISpeechRecognitionService.isInitializing) {
      return 'Initializing...';
    }
    if (!widget.isInitialized) {
      return 'Tap to initialize';
    }
    if (widget.status == 'Starting...' || widget.status == 'Initializing...') {
      return 'Starting...';
    }
    if (widget.status.contains('timeout') ||
        widget.status.contains('Timeout')) {
      return 'Retrying...';
    }
    return widget.isActive ? 'Listening' : 'Tap to activate';
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 25.h,
      right: 4.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Enhanced status indicator with initialization feedback
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _statusColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading indicator for initialization
                if (AISpeechRecognitionService.isInitializing)
                  SizedBox(
                    width: 8,
                    height: 8,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.5,
                      color: _statusColor,
                    ),
                  )
                else
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                SizedBox(width: 2.w),
                Text(
                  _statusText,
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: _statusColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 1.h),

          // Enhanced voice toggle button with minimal controlled animations
          GestureDetector(
            onTap:
                widget.isInitialized ||
                        AISpeechRecognitionService.isInitializing
                    ? _handleToggle
                    : null,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _pulseController,
                _breathingController,
              ]),
              builder: (context, child) {
                return Container(
                  // Fixed container size to prevent overflow
                  width: 15.w, // Exact button size
                  height: 15.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Initialization pulse for feedback - very controlled
                      if (AISpeechRecognitionService.isInitializing)
                        Container(
                          width: 15.w, // Same as button size
                          height: 15.w,
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 15.w - 2, // Slightly smaller
                              height: 15.w - 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Outer pulse ring for active state - very controlled
                      if (widget.isActive && widget.visualFeedbackEnabled)
                        Container(
                          width: 15.w, // Same as button size
                          height: 15.w,
                          child: Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 15.w - 2, // Slightly smaller
                              height: 15.w - 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _statusColor.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                              ),
                            ),
                          ),
                        ),

                      // Main button - with minimal breathing animation
                      Transform.scale(
                        scale:
                            widget.isActive && widget.visualFeedbackEnabled
                                ? _breathingAnimation.value
                                : 1.0,
                        child: Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _statusColor,
                            boxShadow: [
                              BoxShadow(
                                color: _statusColor.withValues(alpha: 0.2),
                                blurRadius: widget.isActive ? 6 : 4,
                                spreadRadius: 0, // No spread to prevent growth
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Loading indicator for initialization
                              if (AISpeechRecognitionService.isInitializing)
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                CustomIconWidget(
                                  iconName: widget.isActive ? 'mic' : 'mic_off',
                                  color: Colors.white,
                                  size: 20,
                                ),

                              // Enhanced AI indicator badge
                              if (!AISpeechRecognitionService.isInitializing)
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: EdgeInsets.all(1),
                                    decoration: BoxDecoration(
                                      color:
                                          widget.isActive
                                              ? Colors.green
                                              : widget.isInitialized
                                              ? Colors.blue
                                              : Colors.grey[600],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      'AI',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 6.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Enhanced service indicator with initialization status
          SizedBox(height: 0.5.h),
          if (AISpeechRecognitionService.isInitializing)
            Text(
              'Setting up...',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.blue,
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
              ),
            )
          else if (widget.isInitialized)
            Text(
              AISpeechRecognitionService.usingLocalSpeechRecognition
                  ? 'Device'
                  : 'OpenAI',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontSize: 8.sp,
                fontWeight: FontWeight.w400,
              ),
            )
          else
            Text(
              'Not Ready',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontSize: 8.sp,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sizer/sizer.dart';

// import '../../../core/app_export.dart';
// import '../../../services/ai_speech_recognition_service.dart';

// class VoiceToggleWidget extends StatefulWidget {
//   final bool isActive;
//   final bool isInitialized;
//   final VoidCallback onToggle;
//   final bool visualFeedbackEnabled;
//   final bool hapticFeedbackEnabled;
//   final String status;

//   const VoiceToggleWidget({
//     super.key,
//     required this.isActive,
//     required this.isInitialized,
//     required this.onToggle,
//     this.visualFeedbackEnabled = true,
//     this.hapticFeedbackEnabled = true,
//     this.status = 'Ready',
//   });

//   @override
//   State<VoiceToggleWidget> createState() => _VoiceToggleWidgetState();
// }

// class _VoiceToggleWidgetState extends State<VoiceToggleWidget>
//     with TickerProviderStateMixin {
//   late AnimationController _pulseController;
//   late AnimationController _breathingController;
//   late Animation<double> _pulseAnimation;
//   late Animation<double> _breathingAnimation;

//   @override
//   void initState() {
//     super.initState();

//     _pulseController = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _breathingController = AnimationController(
//       duration: Duration(milliseconds: 2000),
//       vsync: this,
//     );

//     _pulseAnimation = Tween<double>(
//       begin: 1.0,
//       end: 1.2,
//     ).animate(CurvedAnimation(
//       parent: _pulseController,
//       curve: Curves.easeInOut,
//     ));

//     _breathingAnimation = Tween<double>(
//       begin: 0.95,
//       end: 1.05,
//     ).animate(CurvedAnimation(
//       parent: _breathingController,
//       curve: Curves.easeInOut,
//     ));

//     if (widget.isActive) {
//       _startAnimations();
//     }
//   }

//   @override
//   void didUpdateWidget(VoiceToggleWidget oldWidget) {
//     super.didUpdateWidget(oldWidget);

//     if (oldWidget.isActive != widget.isActive) {
//       if (widget.isActive) {
//         _startAnimations();
//       } else {
//         _stopAnimations();
//       }
//     }
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _breathingController.dispose();
//     super.dispose();
//   }

//   void _startAnimations() {
//     _pulseController.repeat(reverse: true);
//     _breathingController.repeat(reverse: true);
//   }

//   void _stopAnimations() {
//     _pulseController.stop();
//     _breathingController.stop();
//     _pulseController.reset();
//     _breathingController.reset();
//   }

//   void _handleToggle() {
//     if (widget.hapticFeedbackEnabled) {
//       HapticFeedback.lightImpact();
//     }
//     widget.onToggle();
//   }

//   Color get _statusColor {
//     if (!widget.isInitialized) return Colors.grey;
//     if (widget.isActive) return AppTheme.lightTheme.colorScheme.primary;
//     return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
//   }

//   String get _statusText {
//     if (AISpeechRecognitionService.isInitializing) {
//       return 'Initializing...';
//     }
//     if (!widget.isInitialized) {
//       return 'Tap to initialize';
//     }
//     if (widget.status == 'Starting...' || widget.status == 'Initializing...') {
//       return 'Starting...';
//     }
//     if (widget.status.contains('timeout') ||
//         widget.status.contains('Timeout')) {
//       return 'Retrying...';
//     }
//     return widget.isActive ? 'Listening' : 'Tap to activate';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       bottom: 25.h,
//       right: 4.w,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           // Enhanced status indicator with initialization feedback
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
//             decoration: BoxDecoration(
//               color: _statusColor.withValues(alpha: 0.1),
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: _statusColor.withValues(alpha: 0.3),
//                 width: 1,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Loading indicator for initialization
//                 if (AISpeechRecognitionService.isInitializing)
//                   SizedBox(
//                     width: 8,
//                     height: 8,
//                     child: CircularProgressIndicator(
//                       strokeWidth: 1.5,
//                       color: _statusColor,
//                     ),
//                   )
//                 else
//                   Container(
//                     width: 8,
//                     height: 8,
//                     decoration: BoxDecoration(
//                       color: _statusColor,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                 SizedBox(width: 2.w),
//                 Text(
//                   _statusText,
//                   style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                     color: _statusColor,
//                     fontWeight: FontWeight.w500,
//                     fontSize: 10.sp,
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           SizedBox(height: 1.h),

//           // Enhanced voice toggle button with initialization feedback
//           GestureDetector(
//             onTap: widget.isInitialized ||
//                     AISpeechRecognitionService.isInitializing
//                 ? _handleToggle
//                 : null,
//             child: AnimatedBuilder(
//               animation:
//                   Listenable.merge([_pulseController, _breathingController]),
//               builder: (context, child) {
//                 final scale = widget.isActive && widget.visualFeedbackEnabled
//                     ? _breathingAnimation.value
//                     : 1.0;

//                 return Transform.scale(
//                   scale: scale,
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       // Initialization pulse for feedback
//                       if (AISpeechRecognitionService.isInitializing)
//                         Transform.scale(
//                           scale: _pulseAnimation.value,
//                           child: Container(
//                             width: 18.w,
//                             height: 18.w,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: Colors.blue.withValues(alpha: 0.4),
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),

//                       // Outer pulse ring for active state
//                       if (widget.isActive && widget.visualFeedbackEnabled)
//                         Transform.scale(
//                           scale: _pulseAnimation.value,
//                           child: Container(
//                             width: 18.w,
//                             height: 18.w,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: _statusColor.withValues(alpha: 0.4),
//                                 width: 2,
//                               ),
//                             ),
//                           ),
//                         ),

//                       // Main button
//                       Container(
//                         width: 15.w,
//                         height: 15.w,
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           color: _statusColor,
//                           boxShadow: [
//                             BoxShadow(
//                               color: _statusColor.withValues(alpha: 0.3),
//                               blurRadius: widget.isActive ? 12 : 8,
//                               spreadRadius: widget.isActive ? 2 : 0,
//                             ),
//                           ],
//                         ),
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             // Loading indicator for initialization
//                             if (AISpeechRecognitionService.isInitializing)
//                               SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: Colors.white,
//                                 ),
//                               )
//                             else
//                               CustomIconWidget(
//                                 iconName: widget.isActive ? 'mic' : 'mic_off',
//                                 color: Colors.white,
//                                 size: 20,
//                               ),

//                             // Enhanced AI indicator badge
//                             if (!AISpeechRecognitionService.isInitializing)
//                               Positioned(
//                                 bottom: 0,
//                                 right: 0,
//                                 child: Container(
//                                   padding: EdgeInsets.all(1),
//                                   decoration: BoxDecoration(
//                                     color: widget.isActive
//                                         ? Colors.green
//                                         : widget.isInitialized
//                                             ? Colors.blue
//                                             : Colors.grey[600],
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                         color: Colors.white, width: 1),
//                                   ),
//                                   child: Text(
//                                     'AI',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 6.sp,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),
//           ),

//           // Enhanced service indicator with initialization status
//           SizedBox(height: 0.5.h),
//           if (AISpeechRecognitionService.isInitializing)
//             Text(
//               'Setting up...',
//               style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                 color: Colors.blue,
//                 fontSize: 8.sp,
//                 fontWeight: FontWeight.w500,
//               ),
//             )
//           else if (widget.isInitialized)
//             Text(
//               AISpeechRecognitionService.usingLocalSpeechRecognition
//                   ? 'Device'
//                   : 'OpenAI',
//               style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                 color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
//                 fontSize: 8.sp,
//                 fontWeight: FontWeight.w400,
//               ),
//             )
//           else
//             Text(
//               'Not Ready',
//               style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
//                 color: Colors.grey,
//                 fontSize: 8.sp,
//                 fontWeight: FontWeight.w400,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
