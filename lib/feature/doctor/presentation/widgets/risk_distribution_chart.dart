import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class RiskDistributionChart extends StatelessWidget {
  const RiskDistributionChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 156,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tren Risiko Pasien',
            style: AppTextStyles.labelLarge.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  width: 76,
                  height: 76,
                  child: CustomPaint(
                    painter: _DonutGaugePainter(
                      highRatio: 0.15,
                      medRatio: 0.35,
                      lowRatio: 0.50,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLegendItem('Tinggi (15%)', const Color(0xFFEF4444)),
                      const SizedBox(height: 4),
                      _buildLegendItem('Sedang (35%)', const Color(0xFFF59E0B)),
                      const SizedBox(height: 4),
                      _buildLegendItem('Rendah (50%)', const Color(0xFF10B981)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            fontSize: 10,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DonutGaugePainter extends CustomPainter {
  final double highRatio;
  final double medRatio;
  final double lowRatio;

  _DonutGaugePainter({
    required this.highRatio,
    required this.medRatio,
    required this.lowRatio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final strokeWidth = 8.0;

    final paintHigh = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintMed = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final paintLow = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // We start from top (-pi / 2)
    double startAngle = -math.pi / 2;

    // Draw Low Risk
    final double sweepLow = 2 * math.pi * lowRatio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepLow,
      false,
      paintLow,
    );
    startAngle += sweepLow;

    // Draw Medium Risk
    final double sweepMed = 2 * math.pi * medRatio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepMed,
      false,
      paintMed,
    );
    startAngle += sweepMed;

    // Draw High Risk
    final double sweepHigh = 2 * math.pi * highRatio;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepHigh,
      false,
      paintHigh,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
