import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../core/colors.dart';
import '../core/models/booking.dart' as api;
import '../core/widgets/bottom_navbar.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/primary_button.dart';
import 'pdf_page.dart';

class PaymentSuccessPage extends StatelessWidget {
  const PaymentSuccessPage({
    super.key,
    required this.hotel,
    required this.booking,
  });

  final UiHotel hotel;
  final api.Booking booking;

  @override
  Widget build(BuildContext context) {
    final qrPayload = booking.qrCode?.isNotEmpty == true
        ? booking.qrCode!
        : booking.bookingCode;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Bukti Pemesanan'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            const CircleAvatar(
              radius: 34,
              backgroundColor: Color(0xFFDFF8EA),
              child: Icon(Icons.check_circle, size: 44, color: AppColors.success),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pembayaran Berhasil',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pemesanan Anda berhasil dikonfirmasi. Simpan bukti digital ini untuk check-in.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, height: 1.45, color: AppColors.muted),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .08),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      HotelImage(kind: hotel.image, height: 96, width: 106),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              booking.hotel?.name ?? hotel.name,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${booking.room?.name ?? 'Kamar'} - ${booking.nights} malam',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _miniRow('ID Pesanan', booking.bookingCode),
                            _miniRow('Tanggal', '${_date(booking.checkIn)} - ${_date(booking.checkOut)}'),
                            _miniRow('Pembayaran', booking.paymentMethod ?? '-'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 26),
                  Row(
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          color: AppColors.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _rupiah(booking.totalPrice),
                        style: const TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Kode QR Digital',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            Center(
              child: InkWell(
                onTap: () => _openPdf(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: QrImageView(
                    data: qrPayload,
                    size: 148,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tekan QR untuk melihat bukti pembayaran PDF',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.muted),
            ),
            const SizedBox(height: 18),
            PrimaryButton(
              text: 'Lihat Bukti PDF',
              icon: Icons.picture_as_pdf_outlined,
              onPressed: () => _openPdf(context),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1)),
                (_) => false,
              ),
              child: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
      ),
    );
  }

  void _openPdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PdfPage(hotel: hotel, booking: booking),
      ),
    );
  }

  Widget _miniRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 68,
            child: Text(label, style: const TextStyle(color: AppColors.muted, fontSize: 9)),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  String _date(DateTime value) => '${value.day} ${_month(value.month)} ${value.year}';

  String _month(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[month - 1];
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
}
