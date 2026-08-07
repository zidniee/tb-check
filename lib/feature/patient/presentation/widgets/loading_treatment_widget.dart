import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/app_theme.dart';

class LoadingTreatmentWidget extends StatelessWidget {
  const LoadingTreatmentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Shimmer.fromColors(
        baseColor: AppColors.border.withOpacity(0.4),
        highlightColor: Colors.white.withOpacity(0.6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Treatment Status Card skeleton
            _buildCardSkeleton(height: 160),
            const SizedBox(height: 16),
            // Today's schedules card skeleton
            _buildCardSkeleton(height: 180),
            const SizedBox(height: 16),
            // Next reminder card skeleton
            _buildCardSkeleton(height: 80),
            const SizedBox(height: 16),
            // Statistics card skeleton
            _buildCardSkeleton(height: 140),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSkeleton({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 120,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity * 0.7,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity * 0.4,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
