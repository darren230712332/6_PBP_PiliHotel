import 'package:flutter/material.dart';

import '../colors.dart';

class PiliLogo extends StatelessWidget {
  const PiliLogo({
    super.key,
    this.size = 56,
    this.showText = false,
    this.textColor = AppColors.text,
  });

  final double size;
  final bool showText;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'P',
              style: TextStyle(
                fontSize: size * .42,
                fontWeight: FontWeight.w900,
                color: AppColors.gradientTop,
              ),
            ),
            Text(
              'PiliHotel',
              style: TextStyle(
                fontSize: size * .105,
                fontWeight: FontWeight.w800,
                color: AppColors.gradientTop,
              ),
            ),
          ],
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
