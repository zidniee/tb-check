import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/care_entities.dart';
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

          final schedules = state.schedules.valueOrNull ?? [];
          final history = state.history.valueOrNull ?? [];

          // 1. Calculate active configured schedules frequency
          final dailyScheduledCount = schedules.where((s) => s.isActive).length.clamp(1, 99);

          // 2. Group history logs by date to count successful vs missed/pending days
          final Map<String, List<LogEntity>> logsByDate = {};
          for (final log in history) {
            logsByDate.putIfAbsent(log.reminderDate, () => []).add(log);
          }

          int successfulDays = 0;
          int missedDays = 0;
          int pendingDays = 0;

          for (final date in logsByDate.keys) {
            final dayLogs = logsByDate[date]!;
            final takenCount = dayLogs.where((log) => log.status == 'TAKEN').length;
            final missedCount = dayLogs.where((log) => log.status == 'MISSED').length;
            final pendingCount = dayLogs.where((log) => log.status == 'PENDING').length;

            if (takenCount >= dailyScheduledCount) {
              successfulDays++;
            } else if (missedCount > 0) {
              missedDays++;
            } else if (pendingCount > 0) {
              pendingDays++;
            }
          }

          final totalDays = successfulDays + missedDays + pendingDays;
          final activeTotalDays = successfulDays + missedDays;
          final double rate = activeTotalDays > 0 ? (successfulDays / activeTotalDays) * 100.0 : 0.0;

          // 3. Calculate daily compliance for the last 7 days dynamically
          final now = DateTime.now();
          final List<double> chartPoints = [];
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
            
            final dayLogs = history.where((log) => log.reminderDate == dateStr).toList();
            if (dayLogs.isEmpty) {
              chartPoints.add(100.0); // Default to 100% if no logs yet
            } else {
              final takenCount = dayLogs.where((log) => log.status == 'TAKEN').length;
              final dailyCompliance = (takenCount / dailyScheduledCount) * 100.0;
              chartPoints.add(dailyCompliance.clamp(0.0, 100.0));
            }
          }

          // 4. Generate dynamic X-axis labels
          final List<String> chartLabels = [];
          final dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
          for (int i = 6; i >= 0; i--) {
            final date = now.subtract(Duration(days: i));
            if (i == 0) {
              chartLabels.add('Hari Ini');
            } else {
              chartLabels.add(dayNames[date.weekday % 7]);
            }
          }

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
                      _buildMetricRow('Total Hari Terapi', '$totalDays Hari', AppColors.primary),
                      const Divider(height: 24),
                      _buildMetricRow('Hari Berhasil Minum', '$successfulDays Hari', AppColors.success),
                      const Divider(height: 24),
                      _buildMetricRow('Hari Terlewat', '$missedDays Hari', Colors.redAccent),
                      const Divider(height: 24),
                      _buildMetricRow('Hari Tertunda', '$pendingDays Hari', AppColors.textSecondary.withOpacity(0.6)),
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
                      Padding(
                        padding: const EdgeInsets.only(left: 35),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: chartLabels.map((label) {
                            final isToday = label == 'Hari Ini';
                            return Text(
                              label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? AppColors.primary : AppColors.textSecondary,
                              ),
                            );
                          }).toList(),
                        ),
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

    final double chartLeft = 35.0; // Left margin for Y-axis labels
    final double chartRight = size.width;
    final double chartWidth = chartRight - chartLeft;
    final double widthBetweenPoints = chartWidth / (points.length - 1);

    // Scale compliance values (0-100) to height of the canvas (max height is size.height * 0.7)
    double getY(double val) {
      final percentage = val / 100.0;
      return size.height - (percentage * size.height * 0.7) - 15;
    }

    // 1. Draw horizontal grid lines (dashed) and Y-axis labels
    final paintGrid = Paint()
      ..color = AppColors.border.withOpacity(0.4)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    void drawDashedLine(Canvas canvas, double x1, double y, double x2, Paint paint) {
      const dashWidth = 4.0;
      const dashSpace = 4.0;
      double currentX = x1;
      while (currentX < x2) {
        canvas.drawLine(Offset(currentX, y), Offset(currentX + dashWidth, y), paint);
        currentX += dashWidth + dashSpace;
      }
    }

    void drawYLabel(String text, double y) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - textPainter.height / 2));
    }

    // Draw reference lines & labels at 100%, 50%, 0%
    drawDashedLine(canvas, chartLeft, getY(100), chartRight, paintGrid);
    drawYLabel('100%', getY(100));

    drawDashedLine(canvas, chartLeft, getY(50), chartRight, paintGrid);
    drawYLabel('50%', getY(50));

    drawDashedLine(canvas, chartLeft, getY(0), chartRight, paintGrid);
    drawYLabel('0%', getY(0));

    // 2. Draw smooth line chart path and shadow
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

    path.moveTo(chartLeft, getY(points[0]));
    shadowPath.moveTo(chartLeft, size.height);
    shadowPath.lineTo(chartLeft, getY(points[0]));

    for (int i = 0; i < points.length - 1; i++) {
      final x1 = chartLeft + i * widthBetweenPoints;
      final y1 = getY(points[i]);
      final x2 = chartLeft + (i + 1) * widthBetweenPoints;
      final y2 = getY(points[i + 1]);

      final controlX1 = x1 + (widthBetweenPoints / 2);
      final controlY1 = y1;
      final controlX2 = x1 + (widthBetweenPoints / 2);
      final controlY2 = y2;

      path.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
      shadowPath.cubicTo(controlX1, controlY1, controlX2, controlY2, x2, y2);
    }

    shadowPath.lineTo(chartRight, size.height);
    shadowPath.close();

    canvas.drawPath(shadowPath, paintShadow);
    canvas.drawPath(path, paintLine);

    // 3. Draw dots and values on top of points
    final paintDotOuter = Paint()..color = AppColors.primaryLight;
    final paintDotInner = Paint()..color = AppColors.primary;

    for (int i = 0; i < points.length; i++) {
      final x = chartLeft + i * widthBetweenPoints;
      final y = getY(points[i]);

      canvas.drawCircle(Offset(x, y), 6, paintDotOuter);
      canvas.drawCircle(Offset(x, y), 3, paintDotInner);

      final valuePainter = TextPainter(
        text: TextSpan(
          text: '${points[i].toStringAsFixed(0)}%',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      valuePainter.layout();
      valuePainter.paint(canvas, Offset(x - valuePainter.width / 2, y - 18));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
