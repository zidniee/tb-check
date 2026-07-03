import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ScreeningStepperHeader extends StatelessWidget {
  final int currentStep;

  const ScreeningStepperHeader({
    super.key,
    required this.currentStep,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStepIndicator(0, 'Kuesioner', currentStep >= 0, currentStep == 0),
        Expanded(
          child: Container(
            height: 2,
            color: currentStep >= 1 ? AppColors.primary : AppColors.border,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
        ),
        _buildStepIndicator(1, 'Rekam Batuk', currentStep >= 1, currentStep == 1),
      ],
    );
  }

  Widget _buildStepIndicator(int index, String label, bool isCompleted, bool isActive) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.textSecondary.withOpacity(0.4);
    
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? activeColor
                : (isCompleted ? activeColor.withOpacity(0.1) : Colors.transparent),
            border: Border.all(
              color: isCompleted ? activeColor : inactiveColor,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted && !isActive
                ? Icon(Icons.check_rounded, color: activeColor, size: 16)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : (isCompleted ? activeColor : inactiveColor),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            fontSize: 13,
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
