import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/colors.dart';
import '../core/widgets/custom_appbar.dart';

class QrPage extends StatelessWidget {
  const QrPage({super.key, this.data = 'PiliHotel'});

  final String data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'QR Check In'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: QrImageView(
                data: data,
                size: 190,
                backgroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Tunjukkan QR ini saat check-in hotel',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
