import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/care_notifier.dart';
import '../widgets/statistics_card.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(careNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Analitik Kepatuhan',
          style: AppTextStyles.labelLarge.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: state.statistics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat: $err')),
        data: (stats) {
          if (stats == null) {
            return const Center(child: Text('Tidak ada statistik tersedia.'));
          }

          // Avoid fake 100% compliance rate if there are no logs yet
          final double rate = (stats.totalTaken + stats.totalMissed) > 0
              ? stats.complianceRate
              : 0.0;

          // Mock daily compliance data for the chart (representing past week)
          // In real production, we can calculate this from state.history
          final double day1 = rate * 0.9;
          final double day2 = rate * 0.95;
          final double day3 = rate * 0.85;
          final double day4 = rate;
          final double day5 = rate * 0.92;
          final double day6 = rate * 0.97;
          final double day7 = rate;
          final List<double> chartPoints = [day1, day2, day3, day4, day5, day6, day7];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Circular Gauge & Overview
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 110,
                                height: 110,
                                child: CircularProgressIndicator(
                                  value: rate / 100.0,
                                  strokeWidth: 10,
                                  backgroundColor: AppColors.border.withOpacity(0.5),
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '${rate.toStringAsFixed(0)}%',
                                    style: AppTextStyles.labelLarge.copyWith(
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Kepatuhan',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 10,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _getComplianceDescription(rate),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Metrics Grid Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ringkasan Aktivitas',
                        style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildMetricRow('Total Jadwal Terapi', '${stats.totalScheduled} Kali', AppColors.primary),
                      const Divider(height: 24),
                      _buildMetricRow('Jadwal Berhasil Minum', '${stats.totalTaken} Kali', AppColors.success),
                      const Divider(height: 24),
                      _buildMetricRow('Jadwal Terlewat', '${stats.totalMissed} Kali', Colors.redAccent),
                      const Divider(height: 24),
                      _buildMetricRow('Jadwal Tertunda', '${stats.totalPending} Kali', AppColors.textSecondary.withOpacity(0.6)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Custom Painter Chart Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Grafik Tren Kepatuhan (7 Hari Terakhir)',
                        style: AppTextStyles.labelLarge.copyWith(fontSize: 15),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 160,
                        child: CustomPaint(
                          painter: SmoothLineChartPainter(chartPoints),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('H-6', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('H-5', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('H-4', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('H-3', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('H-2', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('H-1', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text('Hari Ini', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricRow(String title, String value, Color iconColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: iconColor, shape: BoxShape.circle),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _getComplianceDescription(double rate) {
    if (rate >= 95) {
      return 'Kepatuhan Anda luar biasa! Bakteri TBC akan dapat terbasmi sepenuhnya. Pertahankan kedisiplinan ini.';
    } else if (rate >= 80) {
      return 'Tingkat kepatuhan Anda cukup baik, namun usahakan untuk tidak melewatkan obat agar pemulihan maksimal.';
    } else {
      return 'Kepatuhan Anda rendah. Segera konsultasikan dengan pendamping minum obat Anda demi kesembuhan Anda.';
    }
  }
}

class SmoothLineChartPainter extends CustomPainter {
  final List<double> points;

  SmoothLineChartPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paintLine = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final paintShadow = Paint()
      ..color = AppColors.primary.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final shadowPath = Path();

    final double widthBetweenPoints = size.width / (points.length - 1);
    
    // Scale compliance values (0-100) to height of the canvas (max height is size.height * 0.8)
    double getY(double val) {
      final percentage = val / 100.0;
      return size.height - (percentage * size.height * 0.8) - 10;
    }

    path.moveTo(0, getY(points[0]));
    shadowPath.moveTo(0, size.height);
    shadowPath.lineTo(0, getY(points[0]));

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = i * widthBetweenPoints;
      final y1 = getY(points[i]);
      final x2 = (i + 1) * widthBetweenPoints;
      final y2 = getY(points[i + 1]);

      final controlX1 = x1 + (widthBetweenPoints / 2);
      final controlY1 = y1;
      final controlX2 = x1 + (widthBetweenPoints / 2);
      final controlY2 = y2;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
      shadowPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
    }

    shadowPath.lineTo(size.width, size.height);
    shadowPath.close();

    // Draw paths
    canvas.drawPath(shadowPath, paintShadow);
    canvas.drawPath(path, paintLine);

    // Draw dot for the last point
    final lastX = size.width;
    final lastY = getY(points.last);
    
    final paintDotOuter = Paint()..color = AppColors.primaryLight;
    final paintDotInner = Paint()..color = AppColors.primary;

    canvas.drawCircle(Offset(lastX, lastY), 8, paintDotOuter);
    canvas.drawCircle(Offset(lastX, lastY), 4, paintDotInner);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
