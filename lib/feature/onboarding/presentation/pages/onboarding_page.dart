import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../widgets/onboarding_slide.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _slides = [
    {
      'icon': Icons.medical_services_rounded,
      'iconColor': AppColors.primary,
      'iconBgColor': AppColors.primaryLight,
      'title': 'Skrining Akustik AI',
      'description': 'Deteksi dini gejala TBC secara instan hanya dengan menganalisis suara batuk Anda menggunakan teknologi on-device AI.',
    },
    {
      'icon': Icons.local_florist_rounded,
      'iconColor': AppColors.success,
      'iconBgColor': AppColors.successLight,
      'title': 'Edukasi Mandiri & Herbal',
      'description': 'Pelajari informasi valid seputar TBC dan temukan panduan olahraga paru serta terapi herbal pendukung yang aman.',
    },
    {
      'icon': Icons.local_hospital_rounded,
      'iconColor': AppColors.secondary,
      'iconBgColor': AppColors.secondaryLight,
      'title': 'Rujukan RS Mitra',
      'description': 'Terhubung langsung dengan rumah sakit mitra terdekat untuk mendapatkan diagnosis medis resmi dan penanganan lebih lanjut.',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _onNextTap() {
    if (_currentIndex < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _currentIndex == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: isLastPage ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: IgnorePointer(
                      ignoring: isLastPage,
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Lewati',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return OnboardingSlide(
                    icon: slide['icon'] as IconData,
                    iconColor: slide['iconColor'] as Color,
                    iconBgColor: slide['iconBgColor'] as Color,
                    title: slide['title'] as String,
                    description: slide['description'] as String,
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 48.0, top: 16.0),
              child: Column(
                children: [
                  // Dot Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNextTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isLastPage ? AppColors.textPrimary : AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLastPage ? 'Mulai Sekarang' : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    final bool isActive = index == _currentIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      height: 8.0,
      width: isActive ? 24.0 : 8.0,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(4.0),
      ),
    );
  }
}
