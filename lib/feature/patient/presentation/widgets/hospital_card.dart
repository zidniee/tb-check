import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/models/hospital_dto.dart';

class HospitalCard extends StatelessWidget {
  final HospitalDTO hospital;
  final String distanceStr;
  final VoidCallback? onTap;
  final bool isSelected;

  const HospitalCard({
    super.key,
    required this.hospital,
    required this.distanceStr,
    this.onTap,
    this.isSelected = false,
  });

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _openMapDirectly() async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=${hospital.latitude},${hospital.longitude}';
    final Uri url = Uri.parse(googleMapsUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.textPrimary.withOpacity(0.02),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hospital Logo or Placeholder
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight : AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Hospital Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hospital.hospitalName,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hospital.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Jarak, Telepon, dsb
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (distanceStr.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distanceStr,
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  const SizedBox.shrink(),
                ],
                
                // Action Buttons
                Row(
                  children: [
                    if (hospital.phone.isNotEmpty) ...[
                      IconButton(
                        onPressed: () => _makePhoneCall(hospital.phone),
                        icon: const Icon(Icons.phone_rounded),
                        color: AppColors.primary,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          padding: const EdgeInsets.all(8),
                          minimumSize: const Size(36, 36),
                        ),
                        iconSize: 18,
                        tooltip: 'Hubungi Rumah Sakit',
                      ),
                      const SizedBox(width: 8),
                    ],
                    IconButton(
                      onPressed: _openMapDirectly,
                      icon: const Icon(Icons.directions_rounded),
                      color: Colors.white,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.all(8),
                        minimumSize: const Size(36, 36),
                      ),
                      iconSize: 18,
                      tooltip: 'Navigasi Peta',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
