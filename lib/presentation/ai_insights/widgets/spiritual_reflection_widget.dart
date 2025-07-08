import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SpiritualReflectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> prompts;

  const SpiritualReflectionWidget({super.key, required this.prompts});

  @override
  State<SpiritualReflectionWidget> createState() =>
      _SpiritualReflectionWidgetState();
}

class _SpiritualReflectionWidgetState extends State<SpiritualReflectionWidget> {
  int _currentPromptIndex = 0;
  bool _isReflecting = false;

  @override
  Widget build(BuildContext context) {
    final currentPrompt = widget.prompts[_currentPromptIndex];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.primaryColor.withValues(alpha: 0.05),
            AppTheme.accentLight.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'self_improvement',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 20,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  'Spiritual Reflection',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.accentLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${_currentPromptIndex + 1}/${widget.prompts.length}',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.accentLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'lightbulb',
                      color: AppTheme.accentLight,
                      size: 16,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      currentPrompt["category"],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Spacer(),
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: AppTheme.textSecondaryLight,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      currentPrompt["duration"],
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  currentPrompt["prompt"],
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isReflecting ? null : _startReflection,
                  icon: CustomIconWidget(
                    iconName: _isReflecting ? 'pause' : 'play_arrow',
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    _isReflecting ? 'Reflecting...' : 'Start Reflection',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    backgroundColor: _isReflecting
                        ? AppTheme.textSecondaryLight
                        : AppTheme.lightTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              IconButton(
                onPressed: _previousPrompt,
                icon: CustomIconWidget(
                  iconName: 'chevron_left',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                ),
              ),
              SizedBox(width: 1.w),
              IconButton(
                onPressed: _nextPrompt,
                icon: CustomIconWidget(
                  iconName: 'chevron_right',
                  color: AppTheme.lightTheme.primaryColor,
                  size: 24,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.lightTheme.primaryColor.withValues(
                    alpha: 0.1,
                  ),
                ),
              ),
            ],
          ),
          if (_isReflecting) ...[
            SizedBox(height: 2.h),
            _buildReflectionTimer(),
          ],
          SizedBox(height: 2.h),
          _buildReflectionTips(),
        ],
      ),
    );
  }

  Widget _buildReflectionTimer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'timer',
                color: AppTheme.lightTheme.primaryColor,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Text(
                'Reflection in Progress',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.lightTheme.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          LinearProgressIndicator(
            backgroundColor: AppTheme.lightTheme.primaryColor.withValues(
              alpha: 0.2,
            ),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.primaryColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Take your time to contemplate deeply',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionTips() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: AppTheme.accentLight.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'tips_and_updates',
                color: AppTheme.accentLight,
                size: 16,
              ),
              SizedBox(width: 2.w),
              Text(
                'Reflection Tips',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  color: AppTheme.accentLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            '• Find a quiet space free from distractions\n• Reflect on the deeper meaning, not just the words\n• Consider how this applies to your daily life\n• Make sincere dua for spiritual growth',
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _startReflection() {
    setState(() {
      _isReflecting = true;
    });

    // Simulate reflection timer
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isReflecting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: Colors.white,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Reflection completed. May Allah accept your contemplation.',
                ),
              ],
            ),
            backgroundColor: AppTheme.successLight,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _previousPrompt() {
    if (_currentPromptIndex > 0) {
      setState(() {
        _currentPromptIndex--;
        _isReflecting = false;
      });
    }
  }

  void _nextPrompt() {
    if (_currentPromptIndex < widget.prompts.length - 1) {
      setState(() {
        _currentPromptIndex++;
        _isReflecting = false;
      });
    }
  }
}
