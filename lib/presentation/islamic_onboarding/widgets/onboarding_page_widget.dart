import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class OnboardingPageWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String arabicText;
  final String arabicTranslation;
  final String hadithQuote;
  final String imageUrl;
  final Color primaryColor;
  final Color accentColor;
  final bool isPermissionPage;
  final VoidCallback? onPermissionRequest;

  const OnboardingPageWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.arabicText,
    required this.arabicTranslation,
    required this.hadithQuote,
    required this.imageUrl,
    required this.primaryColor,
    required this.accentColor,
    this.isPermissionPage = false,
    this.onPermissionRequest,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8.h),

          // Hero Image with Islamic Geometric Border
          _buildHeroImage(),

          SizedBox(height: 4.h),

          // Title Section
          _buildTitleSection(),

          SizedBox(height: 3.h),

          // Arabic Text Section with RTL Support
          _buildArabicSection(),

          SizedBox(height: 3.h),

          // Description Section
          _buildDescriptionSection(),

          SizedBox(height: 3.h),

          // Hadith Quote Section
          _buildHadithSection(),

          if (isPermissionPage) ...[
            SizedBox(height: 3.h),
            _buildPermissionExplanation(),
          ],

          SizedBox(height: 20.h), // Space for bottom controls
        ],
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      width: 70.w,
      height: 25.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomImageWidget(
              imageUrl: imageUrl,
              width: 70.w,
              height: 25.h,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay for better text readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    primaryColor.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
            // Islamic Geometric Pattern Overlay
            Positioned(
              bottom: 2.h,
              right: 4.w,
              child: Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'star',
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: primaryColor,
            height: 1.2,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildArabicSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Arabic Text (RTL)
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              arabicText,
              textAlign: TextAlign.center,
              style: AppTheme.arabicTextStyle(isLight: true).copyWith(
                fontSize: 18.sp,
                color: primaryColor,
                fontWeight: FontWeight.w500,
                height: 1.8,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          // Translation
          Text(
            arabicTranslation,
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.8,
              ),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
        fontSize: 16.sp,
        height: 1.6,
        color: AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.9),
      ),
    );
  }

  Widget _buildHadithSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accentColor, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'format_quote',
                color: accentColor,
                size: 18,
              ),
              SizedBox(width: 2.w),
              Text(
                'Hadith',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  fontSize: 12.sp,
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Text(
            hadithQuote,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              fontStyle: FontStyle.italic,
              height: 1.5,
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionExplanation() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'security',
            color: AppTheme.successLight,
            size: 32,
          ),
          SizedBox(height: 2.h),
          Text(
            'Privacy Protection',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: primaryColor,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Your location data is used only for calculating accurate prayer times and is never shared with third parties. We follow Islamic principles of privacy and trust.',
            textAlign: TextAlign.center,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              fontSize: 11.sp,
              height: 1.4,
              color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
                alpha: 0.7,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildFeatureItem('location_on', 'Prayer Times'),
              _buildFeatureItem('notifications', 'Smart Reminders'),
              _buildFeatureItem('schedule', 'Salah Alignment'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String iconName, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: primaryColor,
            size: 20,
          ),
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
            fontSize: 9.sp,
            color: AppTheme.lightTheme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
          ),
        ),
      ],
    );
  }
}
