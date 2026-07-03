import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class ProfileDatePickerField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final IconData prefixIcon;
  final VoidCallback onTap;

  const ProfileDatePickerField({
    super.key,
    required this.label,
    required this.hintText,
    required this.controller,
    required this.prefixIcon,
    required this.onTap,
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
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
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
