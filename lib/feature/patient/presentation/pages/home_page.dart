import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../education/presentation/pages/education_list_page.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_action_card.dart';

import '../providers/dashboard_provider.dart';
import '../providers/care_provider.dart';
import '../widgets/medication_schedule_card.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../notification/presentation/pages/notifikasi_page.dart';
import 'hospital_list_page.dart';

class HomePage extends StatefulWidget {
  final VoidCallback onStartScreeningTap;

  const HomePage({super.key, required this.onStartScreeningTap});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false).fetchDashboard();
      Provider.of<CareProvider>(context, listen: false).loadCareData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom:
            false, // Allows scroll content to fill behind the bottom navigation bar
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar Header
              _buildTopBar(context),
              const SizedBox(height: 24),

              // Welcome/Greeting Banner
              _buildGreetingBanner(profileProvider.fullName.split(' ').first),
              const SizedBox(height: 24),

              // Medication Schedule Card
              const MedicationScheduleCard(),
              const SizedBox(height: 24),

              // Activity Recaps Header
              DashboardSectionHeader(
                title: 'Ringkasan Aktivitas',
                actionText: 'Detail',
                onActionTap: () {
                  SnackBarUtils.showInfo(
                    context,
                    'Halaman detail aktivitas belum tersedia.',
                  );
                },
              ),
              const SizedBox(height: 12),

              // Activity Recaps Grid (Health Score & Lung Capacity)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: MetricCard(
                        title: 'Skor Kesehatan',
                        headerIcon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        child: _buildHealthScoreWidget(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: MetricCard(
                        title: 'Kapasitas Paru',
                        trailingHeader: Text(
                          'Harian',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        headerIcon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.bar_chart_rounded,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                        child: _buildLungCapacityWidget(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Header
              DashboardSectionHeader(
                title: 'Aksi Cepat',
                actionText: 'Lihat Semua',
                onActionTap: () {
                  SnackBarUtils.showInfo(
                    context,
                    'Daftar semua aksi belum tersedia.',
                  );
                },
              ),
              const SizedBox(height: 12),

              // Quick Actions Content
              _buildQuickActionsList(context),
              const SizedBox(height: 24),

              // Learning Path Header
              const DashboardSectionHeader(title: 'Alur Belajar'),
              const SizedBox(height: 12),

              // Learning Path Card
              _buildLearningPathCard(context),
              const SizedBox(height: 100), // Unified bottom spacing clearance
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              // Styled premium avatar
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E2D3D), Color(0xFF3D6285)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: _buildAvatarImage(profileProvider.profilePicturePath),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo,',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      profileProvider.fullName.isNotEmpty
                          ? profileProvider.fullName
                          : 'Pengguna',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Consumer<NotificationProvider>(
          builder: (context, notificationProvider, _) {
            final unreadCount = notificationProvider.unreadCount;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                _buildIconButton(
                  icon: Icons.notifications_none_rounded,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const NotifikasiPage(),
                      ),
                    ).then((_) {
                      notificationProvider.fetchNotifications();
                    });
                  },
                ),
                if (unreadCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFEA4335), // Red badge
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withOpacity(0.5)),
          ),
          child: Icon(icon, color: AppColors.textPrimary, size: 20),
        ),
      ),
    );
  }

  Widget _buildGreetingBanner(String firstName) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4E7BA7).withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Selamat pagi, $firstName!',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text('☀️', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'AI TBCheck telah menganalisis metrik terbaru Anda. Anda melakukannya dengan sangat baik—mari lanjutkan perjalanan kesehatan Anda.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary.withOpacity(0.7),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBannerBadge('🔥 Streak 5 Hari'),
              const SizedBox(width: 10),
              _buildBannerBadge('✨ 1.420 XP'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBannerBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: AppTextStyles.labelMedium.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHealthScoreWidget() {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(
            painter: _HealthScorePainter(score: 0.92),
            child: Center(
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '92%',
                    style: AppTextStyles.labelMedium.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.arrow_upward_rounded,
              color: AppColors.success,
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              '3% minggu ini',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLungCapacityWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(
          height: 18,
        ), // Added top spacing to push the chart down and align it with the circle gauge
        // Simulated bar charts
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildBarItem(height: 16, isSelected: false),
            _buildBarItem(height: 32, isSelected: false),
            _buildBarItem(
              height: 48,
              isSelected: true,
            ), // Selected active day (purple/lavender)
            _buildBarItem(height: 20, isSelected: false),
          ],
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Kapasitas Paru-Paru',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBarItem({required double height, required bool isSelected}) {
    return Container(
      width: 16,
      height: height,
      decoration: BoxDecoration(
        color: isSelected ? AppColors.secondary : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildQuickActionsList(BuildContext context) {
    return Column(
      children: [
        // 1. Start Screening (Full Width)
        QuickActionCard(
          title: 'Mulai Skrining',
          subtitle: 'Cek kesehatan dalam 2 menit',
          icon: const Icon(
            Icons.add_box_rounded,
            color: Colors.white,
            size: 22,
          ),
          iconBackgroundColor: AppColors.primary,
          cardBackgroundColor: AppColors.primaryLight,
          badgeText: 'AKTIF',
          badgeTextColor: AppColors.primary,
          badgeBackgroundColor: Colors.white,
          onTap: widget.onStartScreeningTap,
        ),
        const SizedBox(height: 12),

        // 2. Academy & Video Library (2 Columns)
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                title: 'Akademi',
                subtitle: 'Modul 4: Herbal',
                icon: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                iconBackgroundColor: AppColors.success,
                cardBackgroundColor: AppColors.successLight,
                isVertical: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EducationListPage(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Pustaka Video',
                subtitle: 'Senam Paru-Paru',
                icon: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                iconBackgroundColor: AppColors.secondary,
                cardBackgroundColor: AppColors.secondaryLight,
                isVertical: true,
                onTap: () {
                  SnackBarUtils.showInfo(
                    context,
                    'Perpustakaan video belum tersedia.',
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Rumah Sakit Mitra (Full Width)
        QuickActionCard(
          title: 'Rumah Sakit Mitra',
          subtitle: 'Cari & temukan faskes rujukan terdekat',
          icon: const Icon(
            Icons.local_hospital_rounded,
            color: Colors.white,
            size: 22,
          ),
          iconBackgroundColor: AppColors.secondary,
          cardBackgroundColor: AppColors.secondaryLight,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const HospitalListPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLearningPathCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // Icon Badge
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(
                    0xFF1E2D3D,
                  ), // Dark blue background matching screenshot
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dasar Respirasi',
                          style: AppTextStyles.labelLarge.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '65%',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Linear progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: const LinearProgressIndicator(
                        value: 0.65,
                        minHeight: 6,
                        backgroundColor: Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Continue learning button (Dark Blue)
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EducationListPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  AppColors.textPrimary, // Unified slate dark blue accent
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Lanjutkan Belajar',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthScorePainter extends CustomPainter {
  final double score;

  _HealthScorePainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Draw background track
    final bgPaint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 1.25,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Draw active track
    final activePaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 1.25,
      math.pi * 1.5 * score,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildAvatarImage(String? path) {
  const defaultIcon = Icon(
    Icons.person_rounded,
    color: Colors.white,
    size: 24,
  );

  if (path == null || path.isEmpty) {
    return defaultIcon;
  }

  if (File(path).existsSync()) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.file(
        File(path),
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => defaultIcon,
      ),
    );
  }

  final String fullUrl = (path.startsWith('http://') || path.startsWith('https://'))
      ? path
      : (path.startsWith('/') ? '${EnvConfig.apiBaseUrl}$path' : '');

  if (fullUrl.isNotEmpty) {
    final bool isInternalApi = fullUrl.startsWith(EnvConfig.apiBaseUrl);

    if (isInternalApi) {
      return FutureBuilder<String?>(
        future: SecureStorageService().getAccessToken(),
        builder: (context, snapshot) {
          final token = snapshot.data;
          return ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              fullUrl,
              headers: (token != null && token.isNotEmpty)
                  ? {'Authorization': 'Bearer $token'}
                  : null,
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => defaultIcon,
            ),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Image.network(
        fullUrl,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => defaultIcon,
      ),
    );
  }

  return defaultIcon;
}
