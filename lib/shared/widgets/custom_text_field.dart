import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final bool showDivider;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.errorText,
    this.validator,
    this.onChanged,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
          style: AppTextStyles.bodyLarge.copyWith(
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.bodyLarge.copyWith(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
            errorText: errorText,
            errorStyle: AppTextStyles.bodySmall.copyWith(
              color: Colors.redAccent,
            ),
            prefixIcon: prefixIcon != null
                ? SizedBox(
                    width: 40,
                    child: Row(
                      children: [
                        Icon(
                          prefixIcon,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        if (showDivider) ...[
                          const SizedBox(width: 8),
                          Container(
                            height: 18,
                            width: 1,
                            color: AppColors.border,
                          ),
                        ],
                      ],
                    ),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 0,
            ),
            suffixIcon: suffixIcon,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.textSecondary,
                width: 1.5,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.primary,
                width: 2.0,
              ),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.redAccent,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.redAccent,
                width: 2.0,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}
