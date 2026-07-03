import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText!,
              style: AppTextStyles.labelMedium.copyWith(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}
