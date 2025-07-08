import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class IslamicLogoWidget extends StatelessWidget {
  const IslamicLogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.primaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.3,
            ),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer geometric pattern
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                  alpha: 0.3,
                ),
                width: 2,
              ),
            ),
          ),

          // Inner geometric pattern
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                  alpha: 0.5,
                ),
                width: 1.5,
              ),
            ),
          ),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Islamic star/crescent symbol
              CustomIconWidget(
                iconName: 'star',
                color: AppTheme.lightTheme.colorScheme.onPrimary,
                size: 8.w.clamp(24.0, 32.0),
              ),

              SizedBox(height: 0.5.h),

              // App name
              Text(
                'Dhikr',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 3.5.w.clamp(12.0, 16.0),
                  letterSpacing: 1.2,
                ),
              ),

              Text(
                'Share',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                    alpha: 0.8,
                  ),
                  fontWeight: FontWeight.w500,
                  fontSize: 2.5.w.clamp(10.0, 12.0),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),

          // Decorative dots around the circle
          ...List.generate(8, (index) {
            final angle = (index * 45) * (3.14159 / 180);
            final radius = 14.w;
            return Positioned(
              left: (30.w / 2) + (radius * cos(angle)) - 1.w,
              top: (30.w / 2) + (radius * sin(angle)) - 1.w,
              child: Container(
                width: 2.w,
                height: 2.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.lightTheme.colorScheme.onPrimary.withValues(
                    alpha: 0.6,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  double cos(double radians) => math.cos(radians);
  double sin(double radians) => math.sin(radians);
}

// Import math for trigonometric functions
