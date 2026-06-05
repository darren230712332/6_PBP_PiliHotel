import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/widgets/hotel_card.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              color: const Color(0xFFEAF4FF),
              child: CustomPaint(painter: _FullMapPainter()),
            ),
          ),
          SafeArea(
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            ),
          ),
          for (final pos in [
            const Offset(90, 170),
            const Offset(250, 240),
            const Offset(150, 360),
          ])
            Positioned(
              left: pos.dx,
              top: pos.dy,
              child: const Icon(
                Icons.location_on,
                color: AppColors.danger,
                size: 34,
              ),
            ),
          Positioned(
            right: 18,
            bottom: 218,
            child: FloatingActionButton.small(
              backgroundColor: Colors.white,
              onPressed: () {},
              child: const Icon(
                Icons.my_location,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hotel Terdekat',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  HotelCard(hotel: hotels.first),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final road = Paint()
      ..color = Colors.white
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 6; i++) {
      canvas.drawLine(
        Offset(-20, 90 + i * 120),
        Offset(size.width + 20, 20 + i * 120),
        road,
      );
      canvas.drawLine(
        Offset(70 + i * 80, -20),
        Offset(20 + i * 80, size.height),
        road,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
