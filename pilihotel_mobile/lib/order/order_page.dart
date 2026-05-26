import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/hotel_card.dart';
import '../core/models/booking.dart' as api;
import '../core/services/booking_service.dart';
import '../review/review_page.dart';
import '../review/review_result_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final BookingService _bookingService = BookingService();
  late final Future<List<api.Booking>> _bookingsFuture = _bookingService.getBookings();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya'),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<api.Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          final bookings = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting && bookings.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && bookings.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat pesanan: ${snapshot.error}'),
              ),
            );
          }

          final orders = bookings
              .map(
                (booking) => _Order(
                  bookingId: booking.id,
                  code: booking.bookingCode,
                  hotelName: booking.hotel?.name ?? 'Hotel',
                  date: '${booking.checkIn.day} ${_month(booking.checkIn.month)} - ${booking.checkOut.day} ${_month(booking.checkOut.month)}',
                  duration: '${booking.nights} Malam',
                  status: booking.status,
                  statusColor: booking.paymentStatus == 'paid' ? AppColors.success : AppColors.muted,
                  image: booking.hotel?.image ?? 'bed',
                  canReview: booking.paymentStatus == 'paid' && booking.checkOut.isBefore(DateTime.now()),
                ),
              )
              .toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            children: [
              Row(
                children: [
                  const Text(
                    'Status Pesanan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      '${orders.length} PESANAN',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final order in orders) _OrderCard(order: order),
            ],
          );
        },
      ),
    );
  }

  String _month(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return months[month - 1];
  }
}

class _Order {
  const _Order({
    required this.bookingId,
    required this.code,
    required this.hotelName,
    required this.date,
    required this.duration,
    required this.status,
    required this.statusColor,
    required this.image,
    required this.canReview,
  });

  final int bookingId;
  final String code;
  final String hotelName;
  final String date;
  final String duration;
  final String status;
  final Color statusColor;
  final String image;
  final bool canReview;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _Order order;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HotelImage(kind: order.image, width: 88, height: 82),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PESANAN ${order.code}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.hotelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${order.date} • ${order.duration}',
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          order.statusColor == AppColors.success
                              ? Icons.check_circle_outline
                              : Icons.circle,
                          color: order.statusColor,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            order.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: order.statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: FilledButton.icon(
              onPressed: () => showPiliDialog(
                context,
                icon: Icons.qr_code_2,
                title: 'Bukti Pesanan',
                message: 'Kode pesanan ${order.code} untuk ${order.hotelName}.',
                buttonText: 'Tutup',
                color: AppColors.primaryBlue,
              ),
              icon: const Icon(Icons.qr_code_2, size: 15),
              label: const Text('Lihat Bukti'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _SoftButton(
                  icon: Icons.rate_review_outlined,
                  label: 'Beri Ulasan',
                  color: AppColors.primaryBlue,
                  onPressed: order.canReview ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewPage(
                        bookingId: order.bookingId,
                        hotelName: order.hotelName,
                        stayInfo: '${order.date} • ${order.duration}',
                        image: order.image,
                      ),
                    ),
                  ) : () => showPiliDialog(
                    context,
                    icon: Icons.lock_clock_outlined,
                    title: 'Review Belum Tersedia',
                    message: 'Ulasan baru bisa ditulis setelah tanggal check-out selesai.',
                    buttonText: 'Mengerti',
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _SoftButton(
                  icon: Icons.visibility_outlined,
                  label: 'Lihat Ulasan',
                  color: AppColors.text,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewResultPage(
                        hotelName: order.hotelName,
                        stayInfo: '${order.date} • ${order.duration}',
                        image: order.image,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SoftButton extends StatelessWidget {
  const _SoftButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 14),
        label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
        style: TextButton.styleFrom(
          foregroundColor: color,
          backgroundColor: const Color(0xFFF0F6FE),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
