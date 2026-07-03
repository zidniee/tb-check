import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SocialButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onTap;
  final double size;

  const SocialButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Ink(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            color: AppColors.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: icon,
          ),
        ),
      ),
    );
  }
}

/// A custom drawn Google logo to avoid asset dependency and ensure sharp rendering.
class GoogleLogo extends StatelessWidget {
  final double size;

  const GoogleLogo({super.key, this.size = 24.0});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _GoogleLogoPainter(),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double r = size.width / 2;
    final double strokeWidth = size.width * 0.22;
    final double deflatedRadius = r - strokeWidth / 2;
    final Rect arcRect = Rect.fromCircle(center: Offset(r, r), radius: deflatedRadius);

    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.square;

    // 1. Red Section (Top)
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(arcRect, -2.356, 1.571, false, paint); // -135 to -45 deg

    // 2. Yellow Section (Right)
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(arcRect, -0.785, 0.785, false, paint); // -45 to 0 deg

    // 3. Green Section (Bottom)
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(arcRect, 0.0, 2.356, false, paint); // 0 to 135 deg

    // 4. Blue Section (Left + Bar)
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(arcRect, 2.356, 1.571, false, paint); // 135 to 225 deg

    // Blue horizontal bar
    final Paint barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;

    // Draw the horizontal bar of 'G'
    canvas.drawRect(
      Rect.fromLTWH(r, r - strokeWidth / 2, r - strokeWidth / 2, strokeWidth),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
