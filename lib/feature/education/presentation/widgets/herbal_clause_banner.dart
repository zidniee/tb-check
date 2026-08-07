import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Mandatory herbal disclaimer banner per SRS §3.3.1.
///
/// Displays the legally-required herbal clause prominently at the top
/// of every education page. Two variants: full and compact.
class HerbalClauseBanner extends StatelessWidget {
  final bool isCompact;

  /// Full-size banner for the list page.
  const HerbalClauseBanner({super.key}) : isCompact = false;

  /// Compact inline banner for the detail page.
  const HerbalClauseBanner.compact({super.key}) : isCompact = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isCompact ? 14.0 : 18.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(isCompact ? 14 : 18),
        border: Border.all(
          color: const Color(0xFFFBC02D).withOpacity(0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFF57F17),
            size: isCompact ? 20 : 24,
          ),
          SizedBox(width: isCompact ? 10 : 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Klausul Herbal',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontSize: isCompact ? 12 : 13,
                    color: const Color(0xFFE65100),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: isCompact ? 4 : 6),
                Text(
                  isCompact
                      ? 'Informasi ini bersifat preventif dan BUKAN pengganti OAT resmi. Konsultasikan dengan dokter Anda.'
                      : 'Informasi fitokimia herbal pencegahan ini murni bersifat preventif untuk menunjang imunitas paru, serta TIDAK BOLEH diposisikan sebagai pengganti Obat Anti Tuberkulosis (OAT) resmi.\n\nSelalu konsultasikan dengan dokter spesialis paru sebelum mengonsumsi bahan herbal bersamaan dengan regimen obat TBC Anda.',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: isCompact ? 11 : 12,
                    color: const Color(0xFF5D4037),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
