import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SnackBarUtils {
  static void showSuccess(BuildContext context, String message) {
    showCustomSnackBar(
      context: context,
      title: 'Success',
      message: message,
      backgroundColor: AppColors.success,
      icon: Icons.check,
    );
  }

  static void showError(BuildContext context, String message) {
    showCustomSnackBar(
      context: context,
      title: 'Error',
      message: message,
      backgroundColor: const Color(0xFFEA4335), // Smooth warning red
      icon: Icons.priority_high_rounded,
    );
  }

  static void showInfo(BuildContext context, String message) {
    showCustomSnackBar(
      context: context,
      title: 'Info',
      message: message,
      backgroundColor: AppColors.secondary, // Royal Lavender matching the mockup image purple
      icon: Icons.question_mark_rounded, // Question mark icon matching the mockup image
    );
  }

  static void showCustomSnackBar({
    required BuildContext context,
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
  }) {
    // Clear any active snackbars immediately to prevent visual queueing delay
    ScaffoldMessenger.of(context).clearSnackBars();

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    double bottomMargin = MediaQuery.of(context).size.height - 140 - MediaQuery.of(context).padding.top - keyboardHeight;
    if (bottomMargin < 0) bottomMargin = 0;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.only(
          bottom: bottomMargin,
          left: 16.0,
          right: 16.0,
        ),
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 3),
        content: Stack(
          clipBehavior: Clip.none,
          children: [
            // Main Card Container
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(14.0),
                boxShadow: [
                  BoxShadow(
                    color: backgroundColor.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Decorative Background Bubbles
                  Positioned(
                    right: -15,
                    top: -15,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.12),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -25,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -15,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  // Content Padding
                  Padding(
                    padding: const EdgeInsets.fromLTRB(48.0, 10.0, 16.0, 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          message,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Overflowing Circle Icon Badge (matching mockup)
            Positioned(
              top: -8,
              left: 12,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
