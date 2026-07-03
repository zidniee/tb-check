import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  const CustomCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: value ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: value ? AppColors.primary : AppColors.textSecondary,
                width: 2.0,
              ),
            ),
            child: value
                ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
