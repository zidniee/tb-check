import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/social_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_header.dart';
import 'otp_page.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    // ADJUST: Shorter header to allocate more room for the extra form fields
    final double headerHeight = screenHeight * 0.28;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SafeArea(
            top: false, // Let the header cover the top status bar area
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Stack(
                children: [
                  const LoginHeader(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: headerHeight * 0.80),
                        
                        // Title Sign up with underline decoration
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign up',
                              style: AppTextStyles.h5.copyWith(
                                fontSize: 36,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 65,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary, // Steel blue theme
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Name Field
                        CustomTextField(
                          label: 'Name',
                          hintText: 'Alex Johnson',
                          prefixIcon: Icons.person_outline_rounded,
                          errorText: authProvider.nameError,
                          onChanged: authProvider.setName,
                          keyboardType: TextInputType.name,
                        ),
                        const SizedBox(height: 20),

                        // Email Field
                        CustomTextField(
                          label: 'Email',
                          hintText: 'demo@email.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          errorText: authProvider.emailError,
                          onChanged: authProvider.setEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 20),

                        // Phone no Field
                        CustomTextField(
                          label: 'Phone no',
                          hintText: '+00 000-0000-000',
                          prefixIcon: Icons.smartphone_rounded,
                          errorText: authProvider.phoneNoError,
                          onChanged: authProvider.setPhoneNo,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        CustomTextField(
                          label: 'Password',
                          hintText: 'enter your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: authProvider.obscurePassword,
                          errorText: authProvider.passwordError,
                          onChanged: authProvider.setPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF9EAAB6),
                              size: 22,
                            ),
                            onPressed: authProvider.toggleObscurePassword,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Confirm Password Field
                        CustomTextField(
                          label: 'Confirm Password',
                          hintText: 'Confirm your password',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: authProvider.obscureConfirmPassword,
                          errorText: authProvider.confirmPasswordError,
                          onChanged: authProvider.setConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              authProvider.obscureConfirmPassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF9EAAB6),
                              size: 22,
                            ),
                            onPressed: authProvider.toggleObscureConfirmPassword,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Create Account Button
                        CustomButton(
                          text: 'Create Account',
                          isLoading: authProvider.isLoading,
                          onPressed: () async {
                            final success = await authProvider.signUp();
                            if (success && context.mounted) {
                              Navigator.push(
                                context,
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                      OtpPage(email: authProvider.email),
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    const begin = Offset(1.0, 0.0);
                                    const end = Offset.zero;
                                    const curve = Curves.easeInOutCubic;
                                    final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                    return SlideTransition(
                                      position: animation.drive(tween),
                                      child: FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      ),
                                    );
                                  },
                                  transitionDuration: const Duration(milliseconds: 400),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 24),

                        // Divider OR Continue With
                        Row(
                          children: [
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(
                                'or continue with',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const Expanded(
                              child: Divider(
                                color: AppColors.border,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Social Logins
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialButton(
                              icon: const GoogleLogo(size: 24),
                              onTap: () {
                                SnackBarUtils.showInfo(context, 'Google Sign Up pressed');
                              },
                            ),
                            const SizedBox(width: 16),
                            SocialButton(
                              icon: const Icon(
                                Icons.apple,
                                color: Colors.black,
                                size: 28,
                              ),
                              onTap: () {
                                SnackBarUtils.showInfo(context, 'Apple Sign Up pressed');
                              },
                            ),
                            const SizedBox(width: 16),
                            SocialButton(
                              icon: const Icon(
                                Icons.facebook,
                                color: Color(0xFF1877F2),
                                size: 28,
                              ),
                              onTap: () {
                                SnackBarUtils.showInfo(context, 'Facebook Sign Up pressed');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Redirect to Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an Account! ",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Go back to Login
                              },
                              child: Text(
                                'Login',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
