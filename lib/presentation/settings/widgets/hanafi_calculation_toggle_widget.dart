import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/prayer_time_service.dart';

class HanafiCalculationToggleWidget extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool>? onChanged;

  const HanafiCalculationToggleWidget({
    super.key,
    this.initialValue = false,
    this.onChanged,
  });

  @override
  State<HanafiCalculationToggleWidget> createState() =>
      _HanafiCalculationToggleWidgetState();
}

class _HanafiCalculationToggleWidgetState
    extends State<HanafiCalculationToggleWidget> {
  bool _isHanafiEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isHanafiEnabled = widget.initialValue;
    _loadHanafiPreference();
  }

  Future<void> _loadHanafiPreference() async {
    try {
      setState(() => _isLoading = true);
      final hanafiPreference =
          await PrayerTimeService.getHanafiCalculationPreference();
      setState(() {
        _isHanafiEnabled = hanafiPreference;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error loading Hanafi preference: $e');
    }
  }

  Future<void> _updateHanafiPreference(bool value) async {
    try {
      setState(() => _isLoading = true);
      await PrayerTimeService.setHanafiCalculationPreference(value);
      setState(() {
        _isHanafiEnabled = value;
        _isLoading = false;
      });

      if (widget.onChanged != null) {
        widget.onChanged!(value);
      }

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Hanafi calculation method enabled for Asr prayer'
                : 'Standard calculation method enabled for Asr prayer',
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      debugPrint('Error updating Hanafi preference: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update prayer calculation method'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 0.5.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 4.w,
          vertical: 1.h,
        ),
        leading: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: 'schedule',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
        title: Text(
          'Hanafi Calculation for Asr',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 0.5.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isHanafiEnabled
                    ? 'Using Hanafi method for Asr prayer time'
                    : 'Using standard method for Asr prayer time',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                'Hanafi school calculates Asr when shadow length equals object height plus original shadow',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.7),
                  fontSize: 10.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        trailing: _isLoading
            ? SizedBox(
                width: 6.w,
                height: 6.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
              )
            : Switch(
                value: _isHanafiEnabled,
                onChanged: _updateHanafiPreference,
                activeColor: AppTheme.lightTheme.colorScheme.primary,
                inactiveThumbColor: AppTheme.lightTheme.colorScheme.outline,
                inactiveTrackColor: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.3),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
        onTap: _isLoading
            ? null
            : () => _updateHanafiPreference(!_isHanafiEnabled),
      ),
    );
  }
}
