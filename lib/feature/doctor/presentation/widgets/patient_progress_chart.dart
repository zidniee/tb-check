import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class PatientProgressChart extends StatelessWidget {
  const PatientProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(16.0),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Perkembangan Pasien',
                style: AppTextStyles.labelLarge.copyWith(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF2DD4BF),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Aktif Skrining',
                    style: AppTextStyles.bodySmall.copyWith(fontSize: 10, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: _BezierChartPainter(),
            ),
          ),
        ],
      ),
    );
  }
}

class _BezierChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    // Define layout padding for labels
    const double leftPadding = 28.0;
    const double bottomPadding = 20.0;
    const double topPadding = 10.0;
    const double rightPadding = 8.0;

    final double chartWidth = width - leftPadding - rightPadding;
    final double chartHeight = height - topPadding - bottomPadding;

    // Draw grid lines (horizontal)
    final gridPaint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final double gridSpacing = chartHeight / 3;
    
    // Draw Y-axis labels and horizontal grid lines
    final yLabels = ['30', '20', '10', '0'];
    for (int i = 0; i <= 3; i++) {
      final y = topPadding + gridSpacing * i;
      
      // Grid line
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(leftPadding + chartWidth, y),
        gridPaint,
      );

      // Y-axis label
      final textSpan = TextSpan(
        text: yLabels[i],
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 9,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(leftPadding - textPainter.width - 6, y - textPainter.height / 2),
      );
    }

    // Chart data points (x ratio, y ratio from bottom of chart area)
    final points = [
      const Offset(0.0, 0.2),
      const Offset(0.2, 0.35),
      const Offset(0.4, 0.3),
      const Offset(0.6, 0.65),
      const Offset(0.8, 0.55),
      const Offset(1.0, 0.95),
    ];

    // Map point values to pixel values
    final pixels = points.map((p) {
      final x = leftPadding + (p.dx * chartWidth);
      final y = topPadding + chartHeight - (p.dy * chartHeight);
      return Offset(x, y);
    }).toList();

    // Create curved line path
    final path = Path();
    path.moveTo(pixels[0].dx, pixels[0].dy);

    for (int i = 0; i < pixels.length - 1; i++) {
      final p1 = pixels[i];
      final p2 = pixels[i + 1];
      final controlPoint1 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p1.dy);
      final controlPoint2 = Offset(p1.dx + (p2.dx - p1.dx) / 2, p2.dy);
      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p2.dx,
        p2.dy,
      );
    }

    // Draw gradient area underneath the line
    final fillPath = Path.from(path);
    fillPath.lineTo(leftPadding + chartWidth, topPadding + chartHeight);
    fillPath.lineTo(leftPadding, topPadding + chartHeight);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x332DD4BF),
          Color(0x002DD4BF),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Draw smooth chart line
    final linePaint = Paint()
      ..color = const Color(0xFF0D9488) // Deep teal medical color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    // Draw points & highlight circles
    final pointPaint = Paint()
      ..color = const Color(0xFF2DD4BF)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final shadowPaint = Paint()
      ..color = const Color(0xFF0D9488).withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    for (int i = 0; i < pixels.length; i++) {
      final p = pixels[i];
      
      // Draw outer shadow ring for the last point
      if (i == pixels.length - 1) {
        canvas.drawCircle(p, 9, shadowPaint);
        canvas.drawCircle(p, 7, Paint()..color = const Color(0xFF0D9488));
      }
      
      canvas.drawCircle(p, 5, pointPaint);
      canvas.drawCircle(p, 5, borderPaint);
    }

    // Draw X-axis month labels
    final xLabels = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun'];
    for (int i = 0; i < xLabels.length; i++) {
      final x = leftPadding + (i * (chartWidth / (xLabels.length - 1)));
      final textSpan = TextSpan(
        text: xLabels[i],
        style: const TextStyle(
          color: Color(0xFF64748B),
          fontSize: 9,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, height - bottomPadding + 5),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
