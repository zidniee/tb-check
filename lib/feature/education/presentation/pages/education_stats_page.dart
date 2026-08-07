import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/education_provider.dart';

/// Learning statistics dashboard page for the patient.
///
/// Shows aggregate progress: total contents, started, completed,
/// and overall learning percentage with a circular gauge.
class EducationStatsPage extends StatefulWidget {
  const EducationStatsPage({super.key});

  @override
  State<EducationStatsPage> createState() => _EducationStatsPageState();
}

class _EducationStatsPageState extends State<EducationStatsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EducationProvider>().fetchLearningStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Statistik Belajar',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Consumer<EducationProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingStats) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            final stats = provider.stats;
            if (stats == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart_rounded,
                        size: 64, color: AppColors.textSecondary.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada data statistik',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Circular progress gauge
                  _buildProgressGauge(stats.overallPercent),
                  const SizedBox(height: 28),

                  // Stats grid
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.library_books_rounded,
                          iconColor: AppColors.primary,
                          iconBg: AppColors.primaryLight,
                          label: 'Total Konten',
                          value: '${stats.totalContents}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.play_circle_rounded,
                          iconColor: AppColors.secondary,
                          iconBg: AppColors.secondaryLight,
                          label: 'Sudah Dimulai',
                          value: '${stats.totalStarted}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.success,
                          iconBg: AppColors.successLight,
                          label: 'Selesai Dibaca',
                          value: '${stats.totalCompleted}',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.hourglass_bottom_rounded,
                          iconColor: const Color(0xFFE65100),
                          iconBg: const Color(0xFFFFF3E0),
                          label: 'Belum Dimulai',
                          value: '${stats.totalNotStarted}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Motivational message
                  _buildMotivationalCard(stats.overallPercent, stats.isAllCompleted),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressGauge(int percent) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Progres Keseluruhan',
            style: AppTextStyles.labelLarge.copyWith(
              fontSize: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 140,
            height: 140,
            child: CustomPaint(
              painter: _ProgressGaugePainter(
                progress: percent / 100,
                color: percent >= 80
                    ? AppColors.success
                    : percent >= 40
                        ? AppColors.primary
                        : AppColors.secondary,
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percent%',
                      style: AppTextStyles.h5.copyWith(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Selesai',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: AppTextStyles.h5.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalCard(int percent, bool isAllCompleted) {
    String emoji;
    String title;
    String message;

    if (isAllCompleted) {
      emoji = '🏆';
      title = 'Selamat!';
      message = 'Anda telah menyelesaikan semua konten edukasi fitokimia herbal. '
          'Pengetahuan Anda tentang pencegahan TBC berbasis herbal kini sangat baik!';
    } else if (percent >= 70) {
      emoji = '🔥';
      title = 'Luar Biasa!';
      message = 'Progres belajar Anda sangat baik. Teruskan membaca untuk '
          'menyelesaikan semua konten edukasi herbal.';
    } else if (percent >= 30) {
      emoji = '💪';
      title = 'Terus Semangat!';
      message = 'Anda sudah memulai perjalanan belajar tentang fitokimia herbal. '
          'Mari lanjutkan untuk memahami lebih banyak tanaman pencegah TBC.';
    } else {
      emoji = '🌿';
      title = 'Mulai Belajar!';
      message = 'Pelajari berbagai tanaman herbal yang dapat membantu menunjang '
          'kesehatan paru-paru Anda. Mulai dari artikel pertama!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 40)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontSize: 16,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 12,
                    color: AppColors.textPrimary.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the circular progress gauge.
class _ProgressGaugePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressGaugePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background track
    final bgPaint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 1.25,
      math.pi * 1.5,
      false,
      bgPaint,
    );

    // Progress track
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi * 1.25,
      math.pi * 1.5 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressGaugePainter old) =>
      old.progress != progress || old.color != color;
}
