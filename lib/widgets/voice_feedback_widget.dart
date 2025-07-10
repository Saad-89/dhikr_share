import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import './custom_icon_widget.dart';

class VoiceFeedbackWidget extends StatefulWidget {
  final bool isActive;
  final String status;
  final Color statusColor;
  final String? detectedPhrase;
  final VoidCallback? onTap;

  const VoiceFeedbackWidget({
    super.key,
    required this.isActive,
    required this.status,
    required this.statusColor,
    this.detectedPhrase,
    this.onTap,
  });

  @override
  State<VoiceFeedbackWidget> createState() => _VoiceFeedbackWidgetState();
}

class _VoiceFeedbackWidgetState extends State<VoiceFeedbackWidget>
    with TickerProviderStateMixin {
  late AnimationController _rippleController;
  late AnimationController _successController;
  late Animation<double> _rippleAnimation;
  late Animation<double> _successAnimation;

  @override
  void initState() {
    super.initState();

    _rippleController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _successController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );

    _successAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.bounceOut),
    );

    // Start ripple animation if active
    if (widget.isActive) {
      _rippleController.repeat();
    }
  }

  @override
  void didUpdateWidget(VoiceFeedbackWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle activation state changes
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _rippleController.repeat();
      } else {
        _rippleController.stop();
      }
    }

    // Handle phrase detection
    if (widget.detectedPhrase != null &&
        widget.detectedPhrase != oldWidget.detectedPhrase) {
      _triggerSuccessAnimation();
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _successController.dispose();
    super.dispose();
  }

  void _triggerSuccessAnimation() {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Visual success animation
    _successController.forward().then((_) {
      _successController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: SizedBox(
        width: 25.w,
        height: 25.w,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple effect for active state
            if (widget.isActive)
              AnimatedBuilder(
                animation: _rippleAnimation,
                builder: (context, child) {
                  return Container(
                    width: 25.w * (1.0 + _rippleAnimation.value * 0.5),
                    height: 25.w * (1.0 + _rippleAnimation.value * 0.5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.statusColor.withValues(
                          alpha: (1.0 - _rippleAnimation.value) * 0.6,
                        ),
                        width: 2,
                      ),
                    ),
                  );
                },
              ),

            // Main circle
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.statusColor,
                boxShadow: widget.isActive
                    ? [
                        BoxShadow(
                          color: widget.statusColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Microphone icon
                    CustomIconWidget(
                      iconName: widget.isActive ? 'mic' : 'mic_off',
                      color: Colors.white,
                      size: 32,
                    ),

                    // Success overlay
                    AnimatedBuilder(
                      animation: _successAnimation,
                      builder: (context, child) {
                        if (_successAnimation.value == 0.0) {
                          return SizedBox.shrink();
                        }

                        return Transform.scale(
                          scale: _successAnimation.value,
                          child: Container(
                            width: 22.w,
                            height: 22.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green.withValues(alpha: 0.9),
                            ),
                            child: Center(
                              child: CustomIconWidget(
                                iconName: 'check',
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Status indicator dot
            Positioned(
              top: 0,
              right: 2.w,
              child: Container(
                width: 3.w,
                height: 3.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isActive ? Colors.green : Colors.grey,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
