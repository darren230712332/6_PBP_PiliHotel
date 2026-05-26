import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../review/review_page.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        'Promo Hotel',
        'Diskon 30% untuk Grand Palace Hotel hari ini.',
        Icons.local_offer_outlined,
      ),
      (
        'Update Booking',
        'Pembayaran berhasil dan pesanan Anda aktif.',
        Icons.receipt_long_outlined,
      ),
      (
        'Reminder Check-in',
        'Check-in Anda dimulai besok pukul 14.00.',
        Icons.alarm_outlined,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            height: 156,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              gradient: const LinearGradient(
                colors: [Color(0xFF162033), Color(0xFF2F80ED)],
              ),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '12:00',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Spacer(),
                Text(
                  'PiliHotel siap menemani perjalanan Anda.',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          for (final item in items)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFEAF4FF),
                    child: Icon(item.$3, color: AppColors.primaryBlue),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${item.$1}\n${item.$2}',
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReviewPage()),
            ),
            child: const Text('Tulis Review Pesanan'),
          ),
        ],
      ),
    );
  }
}
