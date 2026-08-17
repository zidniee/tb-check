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
import '../../data/models/patient_dashboard_dto.dart';
import '../providers/care_provider.dart';
import '../widgets/medication_schedule_card.dart';
import '../../../notification/presentation/providers/notification_provider.dart';
import '../../../notification/presentation/pages/notifikasi_page.dart';
import 'hospital_list_page.dart';
import '../../../appointment/presentation/pages/appointment_list_page.dart';
import '../../../svir/presentation/pages/svir_simulation_page.dart';
import 'main_navigation_page.dart';

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
    final dashboardProvider = Provider.of<DashboardProvider>(context);
    final dashboard = dashboardProvider.dashboardData;
    final isDashboardLoading = dashboardProvider.isLoading;
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
                        child: _buildHealthScoreWidget(dashboard, isDashboardLoading),
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
                        child: _buildLungCapacityWidget(dashboard, isDashboardLoading),
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
                onActionTap: () => _showAllQuickActions(context),
              ),
              const SizedBox(height: 12),

              // Quick Actions Content
              _buildQuickActionsList(context),
              const SizedBox(height: 24),

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


  Widget _buildHealthScoreWidget(PatientDashboardDTO? dashboard, bool isLoading) {
    if (isLoading && dashboard == null) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    final score = dashboard?.healthScore ?? 0;
    final scoreFraction = (score / 100).clamp(0.0, 1.0);
    final scoreChange = dashboard?.healthScoreChange ?? 0;
    final isScoreUp = scoreChange >= 0;

    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: CustomPaint(
            painter: _HealthScorePainter(score: scoreFraction),
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
                    '$score%',
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
            Icon(
              isScoreUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
              color: isScoreUp ? AppColors.success : const Color(0xFFEA4335),
              size: 12,
            ),
            const SizedBox(width: 2),
            Text(
              '${scoreChange.abs()}% minggu ini',
              style: AppTextStyles.bodySmall.copyWith(
                color: isScoreUp ? AppColors.success : const Color(0xFFEA4335),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLungCapacityWidget(PatientDashboardDTO? dashboard, bool isLoading) {
    if (isLoading && dashboard == null) {
      return const SizedBox(
        height: 100,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    final trend = dashboard?.lungCapacityTrend ?? const [];

    if (trend.isEmpty) {
      return SizedBox(
        height: 100,
        child: Center(
          child: Text(
            'Tidak ada data',
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: trend.asMap().entries.map((entry) {
            final int index = entry.key;
            final point = entry.value;
            // Height logic: max height is 48.0, minimum is 8.0
            final double height = (point.percentage / 100.0 * 48.0).clamp(8.0, 48.0);
            final bool isSelected = index == trend.length - 1;

            return Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildBarItem(height: height, isSelected: isSelected),
                const SizedBox(height: 4),
                Text(
                  point.day,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            );
          }).toList(),
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
                subtitle: 'Edukasi & Pencegahan',
                icon: const Icon(
                  Icons.school_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                iconBackgroundColor: AppColors.success,
                cardBackgroundColor: AppColors.successLight,
                isVertical: true,
                onTap: () {
                  context.findAncestorStateOfType<MainNavigationPageState>()?.onTabSelected(2);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                title: 'Janji Temu',
                subtitle: 'Booking Konsultasi',
                icon: const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                iconBackgroundColor: AppColors.secondary,
                cardBackgroundColor: AppColors.secondaryLight,
                isVertical: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AppointmentListPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // 3. Simulasi Penyebaran TBC (Full Width)
        QuickActionCard(
          title: 'Simulasi Penyebaran TBC',
          subtitle: 'Simulasi risiko & laju penularan di populasi',
          icon: const Icon(
            Icons.analytics_rounded,
            color: Colors.white,
            size: 22,
          ),
          iconBackgroundColor: AppColors.primary,
          cardBackgroundColor: AppColors.primaryLight,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const SvirSimulationPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAllQuickActions(BuildContext parentContext) {
    showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pull handle indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Semua Aksi Cepat',
                style: AppTextStyles.labelLarge.copyWith(
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              // Grid or list of actions
              // Action 1: Mulai Skrining
              _buildModalActionItem(
                sheetContext,
                title: 'Mulai Skrining',
                subtitle: 'Cek kesehatan paru Anda dalam 2 menit',
                icon: Icons.add_box_rounded,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  widget.onStartScreeningTap();
                },
              ),
              const SizedBox(height: 12),
              
              // Action 2: Akademi Edukasi
              _buildModalActionItem(
                sheetContext,
                title: 'Akademi Edukasi',
                subtitle: 'Pelajari pencegahan & penyembuhan TBC',
                icon: Icons.school_rounded,
                color: AppColors.success,
                onTap: () {
                  Navigator.pop(sheetContext);
                  parentContext.findAncestorStateOfType<MainNavigationPageState>()?.onTabSelected(2);
                },
              ),
              const SizedBox(height: 12),
              
              // Action 3: Janji Temu
              _buildModalActionItem(
                sheetContext,
                title: 'Janji Temu',
                subtitle: 'Booking jadwal konsultasi dokter',
                icon: Icons.calendar_today_rounded,
                color: AppColors.secondary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (_) => const AppointmentListPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Action 4: Simulasi Epidemiologi
              _buildModalActionItem(
                sheetContext,
                title: 'Simulasi Penyebaran TBC',
                subtitle: 'Prediksi laju penyebaran & risiko di populasi',
                icon: Icons.analytics_rounded,
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (_) => const SvirSimulationPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // Action 5: Rumah Sakit Mitra (Exclusive here!)
              _buildModalActionItem(
                sheetContext,
                title: 'Rumah Sakit Mitra',
                subtitle: 'Fasilitas kesehatan rujukan terdekat',
                icon: Icons.local_hospital_rounded,
                color: AppColors.secondary,
                onTap: () {
                  Navigator.pop(sheetContext);
                  Navigator.push(
                    parentContext,
                    MaterialPageRoute(
                      builder: (_) => const HospitalListPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalActionItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.labelMedium.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
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
