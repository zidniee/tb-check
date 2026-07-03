import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MedicalDisclaimerBanner extends StatelessWidget {
  const MedicalDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6), // Light warm yellow
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFF57C00),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Disclaimer: TBCheck murni skrining awal digital preventif, BUKAN diagnosis medis final.',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xFF5D4037),
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
