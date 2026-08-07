import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App color tokens from Figma design system
class AppColors {
  // Primary Colors (Steel Blue)
  static const Color primary = Color(0xFF4E7BA7);
  static const Color primaryDark = Color(0xFF3D6285);
  static const Color primaryLight = Color(0xFFE8EEF5);

  // Secondary Colors (Royal Lavender)
  static const Color secondary = Color(0xFF7B519C);
  static const Color secondaryDark = Color(0xFF5F3A80);
  static const Color secondaryLight = Color(0xFFF3E8FF);

  // Accent Colors (Sage Green / Success)
  static const Color success = Color(0xFF5F8C4F);
  static const Color successDark = Color(0xFF4E7340);
  static const Color successLight = Color(0xFFE6F4EA);

  // Neutral Colors
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1E2D3D);
  static const Color textSecondary = Color(0xFF7E97A6);
}

/// App typography tokens using Plus Jakarta Sans
class AppTextStyles {
  // Custom Typography scales from Figma using Plus Jakarta Sans
  
  static TextStyle get h1 => GoogleFonts.plusJakartaSans(
        fontSize: 90,
        fontWeight: FontWeight.bold,
        height: 105 / 90,
        color: AppColors.textPrimary,
      );

  static TextStyle get h3 => GoogleFonts.plusJakartaSans(
        fontSize: 75,
        fontWeight: FontWeight.bold,
        height: 105 / 75,
        color: AppColors.textPrimary,
      );

  static TextStyle get h4 => GoogleFonts.plusJakartaSans(
        fontSize: 54,
        fontWeight: FontWeight.bold,
        height: 90 / 54,
        color: AppColors.textPrimary,
      );

  static TextStyle get h5 => GoogleFonts.plusJakartaSans(
        fontSize: 34,
        fontWeight: FontWeight.bold,
        height: 43 / 34,
        color: AppColors.textPrimary,
      );

  static TextStyle get headingSubtitle => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 43 / 32,
        color: AppColors.textPrimary,
      );

  static TextStyle get smallSubtitle => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w500,
        height: 43 / 32,
        color: AppColors.textPrimary,
      );

  static TextStyle get small => GoogleFonts.plusJakartaSans(
        fontSize: 12, // Normalized from Figma table typo (32) to standard body-small 12
        fontWeight: FontWeight.w500,
        height: 20 / 12,
        color: AppColors.textSecondary,
      );

  // Standard Mobile Typography scales for everyday layout development
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: AppColors.textPrimary,
      );

  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );
}

/// Global Application Theme Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.background,
        surfaceContainerHighest: AppColors.surface,
        error: Colors.redAccent,
      ),
      textTheme: TextTheme(
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 2.0),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.redAccent, width: 2.0),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: AppTextStyles.labelLarge,
        ),
      ),
    );
  }
}
