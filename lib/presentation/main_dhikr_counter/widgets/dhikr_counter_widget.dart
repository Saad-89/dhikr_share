import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DhikrCounterWidget extends StatefulWidget {
  final int count;
  final bool useArabicNumerals;
  final Map<String, dynamic> selectedPhrase;

  const DhikrCounterWidget({
    super.key,
    required this.count,
    this.useArabicNumerals = false,
    required this.selectedPhrase,
  });

  @override
  State<DhikrCounterWidget> createState() => _DhikrCounterWidgetState();
}

class _DhikrCounterWidgetState extends State<DhikrCounterWidget>
    with TickerProviderStateMixin {
  late AnimationController _incrementAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.count;

    _incrementAnimationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _incrementAnimationController,
      curve: Curves.elasticOut,
    ));

    _colorAnimation = ColorTween(
      begin: AppTheme.lightTheme.colorScheme.primary,
      end: AppTheme.lightTheme.colorScheme.secondary,
    ).animate(CurvedAnimation(
      parent: _incrementAnimationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(DhikrCounterWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Enhanced debug logging for counter updates
    if (oldWidget.count != widget.count) {
      debugPrint('=== COUNTER WIDGET UPDATE DEBUG ===');
      debugPrint('Counter updated from ${oldWidget.count} to ${widget.count}');
      debugPrint('Last tracked count: $_lastCount');
      debugPrint('Update timestamp: ${DateTime.now()}');

      // Trigger animation on count change
      _incrementAnimationController.forward().then((_) {
        _incrementAnimationController.reverse();
      });

      _lastCount = widget.count;
      debugPrint('Counter widget animation triggered');
      debugPrint('=== END COUNTER WIDGET UPDATE DEBUG ===');
    }
  }

  @override
  void dispose() {
    _incrementAnimationController.dispose();
    super.dispose();
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
      animation: _incrementAnimationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _colorAnimation.value,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.lightTheme.colorScheme.shadow
                      .withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Counter Display with enhanced visual feedback
                Text(
                  _formatNumber(widget.count),
                  style: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),

                // Current phrase indicator
                if (widget.selectedPhrase.isNotEmpty)
                  Text(
                    widget.selectedPhrase['transliteration'] ?? '',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
