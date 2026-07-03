import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final Widget? headerIcon;
  final Widget? trailingHeader;
  final Widget child;

  const MetricCard({
    super.key,
    required this.title,
    this.headerIcon,
    this.trailingHeader,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (headerIcon != null) ...[
                      headerIcon!,
                      const SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // ignore: use_null_aware_elements
              if (trailingHeader != null) ...[
                const SizedBox(width: 6),
                trailingHeader!,
              ],
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
