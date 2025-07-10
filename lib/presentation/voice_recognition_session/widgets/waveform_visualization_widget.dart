import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WaveformVisualizationWidget extends StatelessWidget {
  final bool isListening;
  final bool isPaused;
  final bool isDetecting;
  final AnimationController waveformController;
  final AnimationController pulseController;

  const WaveformVisualizationWidget({
    super.key,
    required this.isListening,
    required this.isPaused,
    required this.isDetecting,
    required this.waveformController,
    required this.pulseController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 25.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDetecting
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.3,
                ),
          width: isDetecting ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Islamic geometric pattern background
          _buildGeometricPattern(),

          // Waveform visualization
          Center(
            child: AnimatedBuilder(
              animation: waveformController,
              builder: (context, child) {
                return CustomPaint(
                  size: Size(80.w, 15.h),
                  painter: WaveformPainter(
                    animation: waveformController,
                    isListening: isListening,
                    isPaused: isPaused,
                    isDetecting: isDetecting,
                    primaryColor: AppTheme.lightTheme.colorScheme.primary,
                    secondaryColor: AppTheme.lightTheme.colorScheme.secondary,
                  ),
                );
              },
            ),
          ),

          // Pulse effect when detecting
          if (isDetecting)
            AnimatedBuilder(
              animation: pulseController,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.primary.withValues(
                        alpha: 1.0 - pulseController.value,
                      ),
                      width: 3 * pulseController.value,
                    ),
                  ),
                );
              },
            ),

          // Status indicator
          Positioned(top: 2.h, right: 4.w, child: _buildStatusIndicator()),

          // Microphone icon
          Positioned(
            bottom: 2.h,
            left: 4.w,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isListening
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline.withValues(
                        alpha: 0.3,
                      ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: isPaused ? 'mic_off' : 'mic',
                size: 20,
                color: isListening
                    ? AppTheme.lightTheme.colorScheme.onPrimary
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeometricPattern() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        size: Size(double.infinity, 25.h),
        painter: GeometricPatternPainter(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(
            alpha: 0.05,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    Color statusColor;
    String statusText;

    if (!isListening) {
      statusColor = AppTheme.lightTheme.colorScheme.outline;
      statusText = 'Ready';
    } else if (isPaused) {
      statusColor = AppTheme.lightTheme.colorScheme.secondary;
      statusText = 'Paused';
    } else if (isDetecting) {
      statusColor = AppTheme.lightTheme.colorScheme.primary;
      statusText = 'Detecting';
    } else {
      statusColor = AppTheme.lightTheme.colorScheme.primary;
      statusText = 'Listening';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            statusText,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isListening;
  final bool isPaused;
  final bool isDetecting;
  final Color primaryColor;
  final Color secondaryColor;

  WaveformPainter({
    required this.animation,
    required this.isListening,
    required this.isPaused,
    required this.isDetecting,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isListening) return;

    final paint = Paint()
      ..color = isDetecting ? primaryColor : secondaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    final waveCount = 5;

    for (int i = 0; i < size.width; i++) {
      final x = i.toDouble();
      final normalizedX = x / size.width;

      double amplitude = isPaused ? 5 : 20;
      if (isDetecting) amplitude *= 2;

      final y = centerY +
          amplitude *
              math.sin(
                2 * math.pi * waveCount * normalizedX +
                    animation.value * 2 * math.pi,
              ) *
              math.sin(math.pi * normalizedX);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw additional harmonics for richer visualization
    if (isListening && !isPaused) {
      paint.color = paint.color.withValues(alpha: 0.5);
      paint.strokeWidth = 1;

      final harmonicPath = Path();
      for (int i = 0; i < size.width; i++) {
        final x = i.toDouble();
        final normalizedX = x / size.width;

        final amplitude = isDetecting ? 15 : 10;
        final y = centerY +
            amplitude *
                math.sin(
                  4 * math.pi * waveCount * normalizedX +
                      animation.value * 3 * math.pi,
                ) *
                math.sin(math.pi * normalizedX) *
                0.5;

        if (i == 0) {
          harmonicPath.moveTo(x, y);
        } else {
          harmonicPath.lineTo(x, y);
        }
      }

      canvas.drawPath(harmonicPath, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class GeometricPatternPainter extends CustomPainter {
  final Color color;

  GeometricPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final spacing = 40.0;

    // Draw Islamic geometric pattern
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        _drawIslamicStar(canvas, paint, Offset(x, y), 15);
      }
    }
  }

  void _drawIslamicStar(
    Canvas canvas,
    Paint paint,
    Offset center,
    double radius,
  ) {
    final path = Path();
    const points = 8;
    const angle = 2 * math.pi / points;

    for (int i = 0; i < points; i++) {
      final x = center.dx + radius * math.cos(i * angle);
      final y = center.dy + radius * math.sin(i * angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
