import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_checkbox.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../../shared/widgets/social_button.dart';
import '../providers/auth_provider.dart';
import '../widgets/login_header.dart';
import 'sign_up_page.dart';
import '../../../patient/presentation/pages/main_navigation_page.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double headerHeight = screenHeight * 0.32;

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
                        // ADJUST: Change 0.66 (e.g. 0.60 to raise text, 0.70 to lower text) to change the "Sign in" position relative to the curve
                        SizedBox(height: headerHeight * 0.80),
                        // Title Sign in with underline decoration
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign in',
                              style: AppTextStyles.h5.copyWith(
                                fontSize: 36,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              // ADJUST: Change width (65) and height (4) to resize the thick underline decoration
                              width: 65,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.primary, // Steel blue theme
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Email Field
                        CustomTextField(
                          label: 'Email',
                          hintText: 'demo@email.com',
                          prefixIcon: Icons.mail_outline_rounded,
                          errorText: authProvider.emailError,
                          onChanged: authProvider.setEmail,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 24),

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
                        const SizedBox(height: 16),

                        // Remember Me & Forgot Password
                        Row(
                          children: [
                            Expanded(
                              child: CustomCheckbox(
                                value: authProvider.rememberMe,
                                onChanged: authProvider.toggleRememberMe,
                                label: 'Remember Me',
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () {
                                SnackBarUtils.showInfo(context, 'Forgot Password flow is not implemented yet.');
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // General Authentication Error (if any)
                        if (authProvider.loginError != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.red.shade200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: Colors.redAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    authProvider.loginError!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.red.shade900,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Login Button
                        CustomButton(
                          text: 'Login',
                          isLoading: authProvider.isLoading,
                          onPressed: () async {
                            final success = await authProvider.login();
                            if (success && context.mounted) {
                              SnackBarUtils.showSuccess(context, 'Login successful!');
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const MainNavigationPage(),
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
                                SnackBarUtils.showInfo(context, 'Google Sign In pressed');
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
                                SnackBarUtils.showInfo(context, 'Apple Sign In pressed');
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
                                SnackBarUtils.showInfo(context, 'Facebook Sign In pressed');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Redirect to Register
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an Account ? ",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) => const SignUpPage(),
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
                              },
                              child: Text(
                                'Sign up',
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
