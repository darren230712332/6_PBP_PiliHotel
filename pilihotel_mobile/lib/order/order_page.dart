import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../booking/payment_success_page.dart';
import '../core/colors.dart';
import '../core/services/notification_service.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/hotel_card.dart';
import '../core/models/booking.dart' as api;
import '../core/services/booking_service.dart';
import '../review/review_page.dart';
import '../review/review_result_page.dart';
import '../booking/payment_page.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final BookingService _bookingService = BookingService();
  Future<List<api.Booking>>? _bookingsFuture;
  List<int> _simulatedCompletedIds = [];

  @override
  void initState() {
    super.initState();
    _refreshBookings();
  }

  void _refreshBookings() {
    SharedPreferences.getInstance()
        .then((prefs) {
          final list =
              prefs.getStringList('simulated_completed_bookings') ?? [];
          setState(() {
            _simulatedCompletedIds = list
                .map((idStr) => int.tryParse(idStr) ?? 0)
                .toList();
            _bookingsFuture = _bookingService.getBookings();
          });
        })
        .catchError((_) {
          setState(() {
            _bookingsFuture = _bookingService.getBookings();
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Pesanan Saya',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: AppColors.text,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.text,
            size: 18,
          ),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: FutureBuilder<List<api.Booking>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          final bookings = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting &&
              bookings.isEmpty) {
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

          final orders = bookings.map((booking) {
            final isCompleted =
                booking.paymentStatus == 'paid' &&
                (booking.checkOut.isBefore(DateTime.now()) ||
                    _simulatedCompletedIds.contains(booking.id));
            final displayStatus = isCompleted
                ? 'Selesai Menginap'
                : booking.status;
            Color displayColor = AppColors.muted;
            if (isCompleted) {
              displayColor = AppColors.success;
            } else if (booking.status == 'Menunggu Check-in') {
              displayColor = AppColors.muted;
            } else if (booking.status == 'Menunggu Pembayaran') {
              displayColor = AppColors.warning;
            }

            return _Order(
              bookingId: booking.id,
              code: booking.bookingCode,
              hotelName: booking.hotel?.name ?? 'Hotel',
              date:
                  '${booking.checkIn.day} ${_month(booking.checkIn.month)} - ${booking.checkOut.day} ${_month(booking.checkOut.month)}',
              duration: '${booking.nights} Malam',
              status: displayStatus,
              statusColor: displayColor,
              image: booking.hotel?.image ?? 'bed',
              canReview: isCompleted,
              rawBooking: booking,
              review: booking.review,
            );
          }).toList();

          return RefreshIndicator(
            onRefresh: () async => _refreshBookings(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
              children: [
                Row(
                  children: [
                    const Text(
                      'Status Pesanan',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
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
                if (orders.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Text(
                        'Belum ada pesanan.',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                  )
                else
                  for (final order in orders)
                    _OrderCard(order: order, onRefresh: _refreshBookings),
              ],
            ),
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
    required this.rawBooking,
    this.review,
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
  final api.Booking rawBooking;
  final api.Review? review;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onRefresh});

  final _Order order;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HotelImage(kind: order.image, width: 80, height: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'PESANAN ${order.code}',
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        if (order.status == 'Menunggu Check-in')
                          const Icon(
                            Icons.verified,
                            color: AppColors.primaryBlue,
                            size: 14,
                          ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      order.hotelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (order.status == 'Menunggu Check-in') ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.muted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ] else if (order.status == 'Menunggu Pembayaran') ...[
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.warning,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                        ] else ...[
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppColors.success,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Expanded(
                          child: Text(
                            order.status,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: order.statusColor,
                              fontSize: 10.5,
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
          const SizedBox(height: 16),
          if (order.rawBooking.paymentStatus == 'paid' && !order.canReview) ...[
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentSuccessPage(
                              hotel: _toUiHotel(order.rawBooking),
                              booking: order.rawBooking,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.qr_code_scanner,
                        size: 14,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Lihat Bukti',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        final list =
                            prefs.getStringList(
                              'simulated_completed_bookings',
                            ) ??
                            [];
                        if (!list.contains(order.bookingId.toString())) {
                          list.add(order.bookingId.toString());
                          await prefs.setStringList(
                            'simulated_completed_bookings',
                            list,
                          );
                        }

                        await NotificationService().triggerDemoNotification(
                          bookingId: order.bookingId,
                          hotelName: order.hotelName,
                          stayInfo: '${order.date} • ${order.duration}',
                          image: order.image,
                          delaySeconds: 1,
                        );

                        onRefresh();
                      },
                      icon: const Icon(
                        Icons.play_circle_outline,
                        size: 14,
                        color: Colors.orange,
                      ),
                      label: const Text(
                        'Simulasi Selesai',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Colors.orange,
                          width: 1.5,
                        ),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              height: 44,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  if (order.rawBooking.paymentStatus == 'paid') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PaymentSuccessPage(
                          hotel: _toUiHotel(order.rawBooking),
                          booking: order.rawBooking,
                        ),
                      ),
                    );
                  } else {
                    showPaymentSheet(
                      context,
                      _toUiHotel(order.rawBooking),
                      total: order.rawBooking.totalPrice,
                      bookingId: order.bookingId,
                    );
                  }
                },
                icon: Icon(
                  order.rawBooking.paymentStatus == 'paid'
                      ? Icons.qr_code_scanner
                      : Icons.payment,
                  size: 16,
                  color: Colors.white,
                ),
                label: Text(
                  order.rawBooking.paymentStatus == 'paid'
                      ? 'Lihat Bukti'
                      : 'Bayar Sekarang',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SoftButton(
                  icon: Icons.edit_outlined,
                  label: order.review != null ? 'Edit Ulasan' : 'Beri Ulasan',
                  color: AppColors.primaryBlue,
                  backgroundColor: const Color(0xFFEAF4FF),
                  onPressed: order.canReview
                      ? () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewPage(
                                bookingId: order.bookingId,
                                hotelName: order.hotelName,
                                stayInfo: '${order.date} • ${order.duration}',
                                image: order.image,
                                existingReview: order.review,
                              ),
                            ),
                          );
                          onRefresh();
                        }
                      : () => showPiliDialog(
                          context,
                          icon: Icons.lock_clock_outlined,
                          title: 'Review Belum Tersedia',
                          message:
                              'Ulasan baru bisa ditulis setelah tanggal check-out selesai.',
                          buttonText: 'Mengerti',
                          color: AppColors.primaryBlue,
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SoftButton(
                  icon: Icons.visibility_outlined,
                  label: 'Lihat Ulasan',
                  color: order.review != null
                      ? AppColors.text.withValues(alpha: 0.8)
                      : const Color(0xFF7A869A),
                  backgroundColor: order.review != null
                      ? const Color(0xFFF0F4F8)
                      : const Color(0xFFF5F7FA),
                  onPressed: order.review != null
                      ? () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewResultPage(
                                review: order.review!,
                                hotelName: order.hotelName,
                                stayInfo: '${order.date} • ${order.duration}',
                                image: order.image,
                              ),
                            ),
                          );
                          onRefresh();
                        }
                      : () => showPiliDialog(
                          context,
                          icon: Icons.info_outline,
                          title: 'Belum Ada Ulasan',
                          message:
                              'Anda belum memberikan ulasan untuk pesanan ini.',
                          buttonText: 'Tutup',
                          color: AppColors.primaryBlue,
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
    required this.backgroundColor,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
    );
  }
}

UiHotel _toUiHotel(api.Booking booking) {
  final hotel = booking.hotel;
  if (hotel == null) {
    return const UiHotel(
      name: 'PiliHotel',
      location: 'Yogyakarta, Indonesia',
      price: 'Rp0',
      rating: 4.5,
      image: 'modern',
      distance: '0 km',
    );
  }
  String imageKey = 'modern';
  final nameLower = hotel.name.toLowerCase();
  if (nameLower.contains('grand palace')) imageKey = 'sea';
  if (nameLower.contains('urban stay')) imageKey = 'modern';
  if (nameLower.contains('sea breeze')) imageKey = 'pool';
  if (nameLower.contains('sunset view')) imageKey = 'sunset';

  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
  final formattedPrice =
      'Rp${hotel.pricePerNight.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';

  return UiHotel(
    name: hotel.name,
    location: hotel.location,
    price: formattedPrice,
    rating: hotel.rating,
    image: imageKey,
    distance: hotel.distance,
  );
}
