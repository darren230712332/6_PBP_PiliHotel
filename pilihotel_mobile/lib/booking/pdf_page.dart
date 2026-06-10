import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

import '../core/colors.dart';
import '../core/models/booking.dart' as api;
import '../core/services/auth_service.dart';
import '../core/widgets/bottom_navbar.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/hotel_card.dart';

class PdfPage extends StatelessWidget {
  const PdfPage({
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

    final hotelName = booking.hotel?.name ?? hotel.name;
    final roomName = booking.room?.name ?? 'Deluxe King Suite';
    final hotelAndRoom = '$hotelName – $roomName';

    int extrasPrice = 0;
    if (booking.extras != null) {
      for (final extra in booking.extras!) {
        extrasPrice += _asInt(extra['price']);
      }
    }
    final basePrice = booking.totalPrice - extrasPrice;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // darker background so the white PDF page pops out
      appBar: const CustomAppBar(title: 'Bukti Pembayaran (PDF)'),
      body: FutureBuilder<Map<String, dynamic>>(
        future: AuthService().getProfile(),
        builder: (context, snapshot) {
          String name = 'Andi Setiawan';
          String email = 'andi.setiawan@email.com';
          if (snapshot.hasData) {
            final user = snapshot.data?['user'];
            if (user != null) {
              name = user is Map ? (user['name'] ?? name) : (user.name ?? name);
              email = user is Map ? (user['email'] ?? email) : (user.email ?? email);
            }
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
            child: Column(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _savePdf(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Rotated green stamp watermark
                          Positioned.fill(
                            child: Center(
                              child: Opacity(
                                opacity: 0.05,
                                child: Transform.rotate(
                                  angle: -0.25,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFF27AE60), width: 3),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'LUNAS',
                                      style: TextStyle(
                                        color: Color(0xFF27AE60),
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 6,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Content on top
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(6),
                                        child: Image.asset(
                                          'assets/images/logo.jpg',
                                          width: 28,
                                          height: 28,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'PiliHotel',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: AppColors.primaryBlue,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'BUKTI PEMBAYARAN RESMI',
                                        style: TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFF1E293B),
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'INV/${booking.checkIn.year}${booking.checkIn.month.toString().padLeft(2, '0')}${booking.checkIn.day.toString().padLeft(2, '0')}/PH/${booking.bookingCode}',
                                        style: const TextStyle(
                                          fontSize: 7.5,
                                          color: Color(0xFF94A3B8),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _sectionHeader('INFORMASI PELANGGAN'),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'NAMA PEMESAN',
                                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          name,
                                          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 10.5, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'EMAIL',
                                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          email,
                                          style: const TextStyle(color: Color(0xFF1E293B), fontSize: 10.5, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _sectionHeader('DETAIL RESERVASI'),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'HOTEL & KAMAR',
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    hotelAndRoom,
                                    style: const TextStyle(color: Color(0xFF1E293B), fontSize: 10.5, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'CHECK-IN',
                                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              _date(booking.checkIn),
                                              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 10.5, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'DURASI',
                                              style: TextStyle(color: Color(0xFF94A3B8), fontSize: 7.5, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              '${booking.nights} Malam',
                                              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 10.5, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _sectionHeader('RINCIAN TRANSAKSI'),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Harga (${booking.nights} Malam)',
                                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        _rupiah(basePrice),
                                        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Layanan Tambahan (Add-ons)',
                                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                                      ),
                                      Text(
                                        _rupiah(extrasPrice),
                                        style: const TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'TOTAL',
                                        style: TextStyle(color: Color(0xFF1E293B), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        _rupiah(booking.totalPrice),
                                        style: const TextStyle(color: AppColors.primaryBlue, fontSize: 13, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const Spacer(),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Text(
                                        'Dokumen sah dari sistem PiliHotel. Simpan sebagai bukti check-in.',
                                        style: TextStyle(color: Color(0xFF94A3B8), fontSize: 8, height: 1.35),
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: QrImageView(
                                          data: qrPayload,
                                          size: 40,
                                          padding: EdgeInsets.zero,
                                          backgroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '#${booking.bookingCode}',
                                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 7, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1)),
                    (_) => false,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Kembali ke Beranda',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _savePdf(context),
                      icon: const Icon(Icons.share_outlined, color: AppColors.primaryBlue, size: 18),
                      label: const Text(
                        'Bagikan',
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1E293B),
                        minimumSize: const Size(160, 46),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 1.5,
            color: AppColors.primaryBlue,
          ),
          const SizedBox(width: 6),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 1.5,
              color: AppColors.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    final file = await _buildPdfFile();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF tersimpan: ${file.path}')),
    );
  }

  Future<File> _buildPdfFile() async {
    final qrPayload = booking.qrCode?.isNotEmpty == true
        ? booking.qrCode!
        : booking.bookingCode;
    final document = pw.Document();

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('PiliHotel', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('BUKTI PEMBAYARAN HOTEL'),
                pw.Divider(height: 30),
                _pdfRow('Nomor Invoice', 'INV-${booking.bookingCode}'),
                _pdfRow('ID Pesanan', booking.bookingCode),
                _pdfRow('Nama Hotel', booking.hotel?.name ?? hotel.name),
                _pdfRow('Kamar', booking.room?.name ?? 'Kamar'),
                _pdfRow('Check-in', _date(booking.checkIn)),
                _pdfRow('Check-out', _date(booking.checkOut)),
                _pdfRow('Durasi', '${booking.nights} malam'),
                _pdfRow('Metode Bayar', booking.paymentMethod ?? '-'),
                pw.Divider(height: 24),
                for (final extra in booking.extras ?? <Map<String, dynamic>>[])
                  _pdfRow(extra['name']?.toString() ?? 'Add-on', _rupiah(_asInt(extra['price']))),
                _pdfRow('TOTAL', _rupiah(booking.totalPrice), bold: true),
                pw.SizedBox(height: 28),
                pw.Center(
                  child: pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: qrPayload,
                    width: 150,
                    height: 150,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Center(child: pw.Text(qrPayload)),
                pw.Spacer(),
                pw.Text('Terima kasih telah memesan melalui PiliHotel.'),
              ],
            ),
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/PiliHotel-${booking.bookingCode}.pdf');
    await file.writeAsBytes(await document.save());
    return file;
  }

  pw.Widget _pdfRow(String label, String value, {bool bold = false}) {
    final style = pw.TextStyle(fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal);
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        children: [
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text(value, style: style),
        ],
      ),
    );
  }



  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
