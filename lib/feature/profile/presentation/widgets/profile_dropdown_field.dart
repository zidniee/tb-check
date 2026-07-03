import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileDropdownField extends StatelessWidget {
  final String label;
  final String initialValue;
  final List<String> items;
  final IconData prefixIcon;
  final ValueChanged<String?> onChanged;

  const ProfileDropdownField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.items,
    required this.prefixIcon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: initialValue,
          items: items.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(prefixIcon, size: 20, color: AppColors.textSecondary),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.textSecondary, width: 1.5),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 2.0),
            ),
          ),
          style: AppTextStyles.bodyLarge.copyWith(fontSize: 15, color: AppColors.textPrimary),
        ),
      ],
    );
  }
}
