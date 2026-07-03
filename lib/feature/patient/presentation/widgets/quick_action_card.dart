import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget icon;
  final Color iconBackgroundColor;
  final Color cardBackgroundColor;
  final String? badgeText;
  final Color? badgeTextColor;
  final Color? badgeBackgroundColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isVertical;

  const QuickActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBackgroundColor,
    required this.cardBackgroundColor,
    required this.onTap,
    this.badgeText,
    this.badgeTextColor,
    this.badgeBackgroundColor,
    this.trailing,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget cardContent = isVertical
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Center(child: icon),
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.labelLarge.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          )
        : Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: badgeBackgroundColor ?? Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badgeText!,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: badgeTextColor ?? AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // ignore: use_null_aware_elements
              if (trailing != null) trailing!,
            ],
          );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.border.withOpacity(0.4),
              width: 1,
            ),
          ),
          child: cardContent,
        ),
      ),
    );
  }
}
