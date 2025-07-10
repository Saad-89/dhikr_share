import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PhraseDetectionIndicatorWidget extends StatelessWidget {
  final String detectedPhrase;
  final double confidence;
  final List<Map<String, dynamic>> dhikrPhrases;

  const PhraseDetectionIndicatorWidget({
    super.key,
    required this.detectedPhrase,
    required this.confidence,
    required this.dhikrPhrases,
  });

  @override
  Widget build(BuildContext context) {
    final phraseData = dhikrPhrases.firstWhere(
      (phrase) => phrase['transliteration'] == detectedPhrase,
      orElse: () => {
        'arabic': '',
        'transliteration': detectedPhrase,
        'meaning': '',
      },
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _getConfidenceColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _getConfidenceColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getConfidenceColor().withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Detection header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'check_circle',
                  size: 20,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phrase Detected',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: _getConfidenceColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    _buildConfidenceIndicator(),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Arabic text
          if (phraseData['arabic']?.isNotEmpty == true)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline.withValues(
                    alpha: 0.3,
                  ),
                  width: 1,
                ),
              ),
              child: Text(
                phraseData['arabic'],
                style: AppTheme.arabicTextStyle(isLight: true).copyWith(
                  fontSize: 20.sp,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),

          SizedBox(height: 1.h),

          // Transliteration
          Text(
            phraseData['transliteration'],
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),

          // Meaning
          if (phraseData['meaning']?.isNotEmpty == true) ...[
            SizedBox(height: 0.5.h),
            Text(
              phraseData['meaning'],
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildConfidenceIndicator() {
    return Row(
      children: [
        Text(
          'Confidence: ',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: confidence,
              child: Container(
                decoration: BoxDecoration(
                  color: _getConfidenceColor(),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          '${(confidence * 100).toInt()}%',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: _getConfidenceColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getConfidenceColor() {
    if (confidence >= 0.8) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (confidence >= 0.6) {
      return const Color(0xFFB8860B); // Warning color
    } else {
      return const Color(0xFF8B4B47); // Error color
    }
  }
}
