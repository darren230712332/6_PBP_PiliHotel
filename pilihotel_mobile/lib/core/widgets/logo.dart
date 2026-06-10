import 'package:flutter/material.dart';

import '../colors.dart';

class PiliLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF6EC6FF),
          Color(0xFF2F80ED),
        ],
      ).createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Draw left skyscraper
    final path1 = Path();
    path1.moveTo(w * 0.33, h * 0.85); // bottom left
    path1.lineTo(w * 0.33, h * 0.45); // left wall
    path1.lineTo(w * 0.38, h * 0.35); // roof peak
    path1.lineTo(w * 0.43, h * 0.45); // right roof slope
    path1.lineTo(w * 0.43, h * 0.85); // right wall
    path1.close();
    canvas.drawPath(path1, paint);

    // Draw middle skyscraper (stem of 'P')
    final path2 = Path();
    path2.moveTo(w * 0.46, h * 0.85); // bottom left
    path2.lineTo(w * 0.46, h * 0.33); // left wall
    path2.lineTo(w * 0.51, h * 0.23); // roof peak
    path2.lineTo(w * 0.56, h * 0.33); // right roof slope
    path2.lineTo(w * 0.56, h * 0.85); // right wall
    path2.close();
    canvas.drawPath(path2, paint);

    // Draw outer loop of the 'P' with top-left curved serif hook
    final pathP = Path();
    // Start at top-left hook tip
    pathP.moveTo(w * 0.36, h * 0.24);
    // Curve up and right to the horizontal top bar of 'P'
    pathP.cubicTo(w * 0.36, h * 0.20, w * 0.40, h * 0.20, w * 0.51, h * 0.20);
    // Outer loop curves
    pathP.cubicTo(
      w * 0.75, h * 0.20,
      w * 0.85, h * 0.32,
      w * 0.85, h * 0.48,
    );
    pathP.cubicTo(
      w * 0.85, h * 0.64,
      w * 0.70, h * 0.72,
      w * 0.52, h * 0.72,
    );
    // Inner cutout loop
    pathP.lineTo(w * 0.52, h * 0.64);
    pathP.cubicTo(
      w * 0.64, h * 0.64,
      w * 0.75, h * 0.58,
      w * 0.75, h * 0.48,
    );
    pathP.cubicTo(
      w * 0.75, h * 0.38,
      w * 0.64, h * 0.32,
      w * 0.52, h * 0.32,
    );
    pathP.close();
    canvas.drawPath(pathP, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PiliLogoCard extends StatelessWidget {
  const PiliLogoCard({super.key, this.size = 76});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: .18),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: EdgeInsets.all(size * 0.12),
          child: Image.asset(
            'assets/images/logo.jpg',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

class PiliLogo extends StatelessWidget {
  const PiliLogo({
    super.key,
    this.size = 56,
    this.showText = false,
    this.textColor = AppColors.text,
    this.useImageAsset = true,
  });

  final double size;
  final bool showText;
  final Color textColor;
  final bool useImageAsset;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.26),
        child: useImageAsset
            ? Padding(
                padding: EdgeInsets.all(size * 0.12),
                child: Image.asset(
                  'assets/images/logo.jpg',
                  fit: BoxFit.contain,
                ),
              )
            : Center(
                child: SizedBox(
                  width: size * 0.55,
                  height: size * 0.55,
                  child: CustomPaint(
                    painter: PiliLogoPainter(),
                  ),
                ),
              ),
      ),
    );

    if (!showText) return logo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logo,
        const SizedBox(width: 12),
        Text(
          'PiliHotel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

