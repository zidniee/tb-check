import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final double? height;
  final Alignment imageAlignment;

  const LoginHeader({
    super.key,
    this.height,
    this.imageAlignment = const Alignment(0.0, 0.60),
  });

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    
    // ADJUST: Uses the custom height if provided, otherwise defaults to 32% of screen height
    final double headerHeight = height ?? (screenHeight * 0.32);

    return ClipPath(
      clipper: LoginHeaderClipper(),
      child: Container(
        height: headerHeight,
        width: double.infinity,
        color: const Color(0xFFD3E5F5), // Fallback color
        child: Image.asset(
          'assets/images/login_head.png',
          fit: BoxFit.cover,
          // ADJUST: Uses the custom image alignment crop point
          alignment: imageAlignment,
          errorBuilder: (context, error, stackTrace) {
            // Fallback UI in case the asset is missing
            return Container(
              color: const Color(0xFFD3E5F5),
              child: const Center(
                child: Icon(
                  Icons.image_not_supported_outlined,
                  size: 64,
                  color: Color(0xFF4A78A4),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LoginHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    
    // ADJUST: Left-edge start height of the curve (lowered to around 2/3 of header height, ~0.67)
    path.lineTo(0, size.height * 0.67);

    // ADJUST: Wave shape coordinates
    // CP1: peak is lowered from 0.38 to 0.54 to stay around 2/3 height. CP2: valley at 1.00. END: right-edge at 0.76.
    path.cubicTo(
      size.width * 0.22,
      size.height * 0.54,
      size.width * 0.55,
      size.height * 1.00,
      size.width,
      size.height * 0.76,
    );

    // Connect to top-right and close
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
