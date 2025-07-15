import 'package:dhikar_share/core/constants/app_colors.dart';
import 'package:dhikar_share/widgets/app_text.dart';
import 'package:flutter/material.dart';

class HanafiCalculationToggleWidget extends StatelessWidget {
  const HanafiCalculationToggleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(
              Icons.schedule,
              color: AppColors.primaryGreen,
              size: 24,
            ),
          ),
        ),
        title: const AppText(
          text: 'Hanafi Calculation for Asr',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AppText(
                text: 'Using Hanafi method for Asr prayer time',
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.black54,
              ),
              SizedBox(height: 6),
              AppText(
                text:
                    'Hanafi school calculates Asr when shadow length equals object height plus original shadow',
                fontSize: 10,
                fontWeight: FontWeight.normal,

                color: AppColors.black54,
              ),
            ],
          ),
        ),
        trailing: Switch(
          value: true, // static dummy value
          onChanged: (_) {}, // no logic
          activeColor: AppColors.primaryGreen,
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.3),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
