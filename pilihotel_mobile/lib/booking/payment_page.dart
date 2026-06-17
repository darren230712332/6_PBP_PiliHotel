import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/booking_service.dart';
import '../core/services/notification_service.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/loading_dialog.dart';
import '../core/widgets/primary_button.dart';
import 'payment_success_page.dart';

void showPaymentSheet(
  BuildContext context,
  UiHotel hotel, {
  required int total,
  required int bookingId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _PaymentSheet(
      hotel: hotel,
      total: total,
      bookingId: bookingId,
    ),
  );
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({
    required this.hotel,
    required this.total,
    required this.bookingId,
  });

  final UiHotel hotel;
  final int total;
  final int bookingId;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  final BookingService _bookingService = BookingService();
  String method = 'wallet';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        22,
        22,
        28 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Konfirmasi Pembayaran',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.field,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                HotelImage(kind: widget.hotel.image, width: 64, height: 54),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${widget.hotel.name}\nDeluxe King Suite • 2 malam',
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Metode Pembayaran',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _PaymentMethodTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'PiliHotel Wallet',
            subtitle: 'Saldo tersedia Rp5.250.000',
            selected: method == 'wallet',
            onTap: () => setState(() => method = 'wallet'),
          ),
          _PaymentMethodTile(
            icon: Icons.credit_card,
            title: 'Transfer Bank',
            subtitle: 'BCA, Mandiri, BRI',
            selected: method == 'bank',
            onTap: () => setState(() => method = 'bank'),
          ),
          const Divider(height: 28),
          Row(
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const Spacer(),
              Text(
                _rupiah(widget.total),
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          PrimaryButton(
            text: _loading ? 'Memproses...' : 'Lanjut Bayar',
            icon: Icons.arrow_forward,
            onPressed: _loading ? null : _payBooking,
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Center(child: Text('Batal')),
          ),
        ],
      ),
    );
  }

  String _rupiah(int value) {
    final text = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      final fromEnd = text.length - i;
      buffer.write(text[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) {
        buffer.write('.');
      }
    }
    return 'Rp$buffer';
  }

  String _month(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    return months[month - 1];
  }

  Future<void> _payBooking() async {
    setState(() => _loading = true);
    showPiliLoadingDialog(context, message: 'Menyelesaikan pembayaran...');

    debugPrint('DEBUG_PAYMENT: Initiating payment for booking ID: ${widget.bookingId}');
    try {
      final methodStr = method == 'wallet' ? 'PiliHotel Wallet' : 'Transfer Bank';
      debugPrint('DEBUG_PAYMENT: Selected method: $methodStr');
      
      final booking = await _bookingService.payBooking(
        widget.bookingId,
        paymentMethod: methodStr,
      );
      debugPrint('DEBUG_PAYMENT: Payment response received. New status: ${booking.status}');

      // Schedule checkin & checkout reminders and trigger a demo notification in 5 seconds
      try {
        await NotificationService().scheduleCheckinReminder(
          bookingId: booking.id,
          hotelName: widget.hotel.name,
          checkinTime: booking.checkIn,
        );
        final stayInfoString = '${booking.checkIn.day} ${_month(booking.checkIn.month)} - ${booking.checkOut.day} ${_month(booking.checkOut.month)} • ${booking.nights} Malam';
        await NotificationService().scheduleCheckoutReminder(
          bookingId: booking.id,
          hotelName: widget.hotel.name,
          checkoutTime: booking.checkOut,
          stayInfo: stayInfoString,
          image: widget.hotel.image,
        );
        await NotificationService().triggerDemoNotification(
          bookingId: booking.id,
          hotelName: widget.hotel.name,
          stayInfo: stayInfoString,
          image: widget.hotel.image,
          delaySeconds: 5,
        );
      } catch (notifErr) {
        debugPrint('DEBUG_PAYMENT: Failed to schedule notifications: $notifErr');
      }

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            hotel: widget.hotel,
            booking: booking,
          ),
        ),
      );
    } catch (e) {
      debugPrint('DEBUG_PAYMENT: Error caught during payment: $e');
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pembayaran gagal: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.primaryBlue : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primaryBlue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '$title\n$subtitle',
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primaryBlue : AppColors.muted,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Payment')));
}
