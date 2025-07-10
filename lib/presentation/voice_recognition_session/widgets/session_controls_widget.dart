import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SessionControlsWidget extends StatelessWidget {
  final bool isListening;
  final bool isPaused;
  final double sensitivity;
  final VoidCallback onStartListening;
  final VoidCallback onStopListening;
  final VoidCallback onPauseResume;
  final Function(double) onSensitivityChanged;
  final VoidCallback onShowPhraseLibrary;
  final VoidCallback onUndoLastDetection;
  final bool canUndo;

  const SessionControlsWidget({
    super.key,
    required this.isListening,
    required this.isPaused,
    required this.sensitivity,
    required this.onStartListening,
    required this.onStopListening,
    required this.onPauseResume,
    required this.onSensitivityChanged,
    required this.onShowPhraseLibrary,
    required this.onUndoLastDetection,
    required this.canUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Start/Stop button
              _buildControlButton(
                icon: isListening ? 'stop' : 'play_arrow',
                label: isListening ? 'Stop' : 'Start',
                onTap: isListening ? onStopListening : onStartListening,
                isPrimary: true,
                isEnabled: true,
              ),

              // Pause/Resume button
              _buildControlButton(
                icon: isPaused ? 'play_arrow' : 'pause',
                label: isPaused ? 'Resume' : 'Pause',
                onTap: onPauseResume,
                isPrimary: false,
                isEnabled: isListening,
              ),

              // Undo button
              _buildControlButton(
                icon: 'undo',
                label: 'Undo',
                onTap: onUndoLastDetection,
                isPrimary: false,
                isEnabled: canUndo,
              ),
            ],
          ),

          SizedBox(height: 3.h),

          // Sensitivity slider
          _buildSensitivitySlider(context),

          SizedBox(height: 2.h),

          // Additional controls
          Row(
            children: [
              Expanded(
                child: _buildSecondaryButton(
                  icon: 'library_books',
                  label: 'Phrase Library',
                  onTap: onShowPhraseLibrary,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSecondaryButton(
                  icon: 'settings',
                  label: 'Settings',
                  onTap: () {
                    // Navigate to settings or show settings modal
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
    required bool isPrimary,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 20.w,
        height: 20.w,
        decoration: BoxDecoration(
          color: isEnabled
              ? (isPrimary
                  ? AppTheme.lightTheme.colorScheme.primary
                  : AppTheme.lightTheme.colorScheme.surface)
              : AppTheme.lightTheme.colorScheme.outline.withValues(
                  alpha: 0.1,
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled
                ? (isPrimary
                    ? AppTheme.lightTheme.colorScheme.primary
                    : AppTheme.lightTheme.colorScheme.outline.withValues(
                        alpha: 0.5,
                      ))
                : AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.3,
                  ),
            width: isPrimary ? 0 : 1,
          ),
          boxShadow: isEnabled && isPrimary
              ? [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 24,
              color: isEnabled
                  ? (isPrimary
                      ? AppTheme.lightTheme.colorScheme.onPrimary
                      : AppTheme.lightTheme.colorScheme.onSurface)
                  : AppTheme.lightTheme.colorScheme.outline,
            ),
            SizedBox(height: 1.h),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: isEnabled
                    ? (isPrimary
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurface)
                    : AppTheme.lightTheme.colorScheme.outline,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivitySlider(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Microphone Sensitivity',
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${(sensitivity * 100).toInt()}%',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.lightTheme.colorScheme.primary,
            inactiveTrackColor:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            thumbColor: AppTheme.lightTheme.colorScheme.primary,
            overlayColor: AppTheme.lightTheme.colorScheme.primary.withValues(
              alpha: 0.2,
            ),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: sensitivity,
            min: 0.1,
            max: 1.0,
            divisions: 9,
            onChanged: onSensitivityChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Low',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'High',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.outline.withValues(
              alpha: 0.5,
            ),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              size: 18,
              color: AppTheme.lightTheme.colorScheme.primary,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
