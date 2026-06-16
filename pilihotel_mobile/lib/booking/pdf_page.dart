import 'dart:io';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../core/colors.dart';
import '../core/services/http_client.dart';
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
    final qrPayload = '${HttpClient.serverUrl}/api/bookings/${booking.bookingCode}/download-pdf';

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
                    onTap: () => _savePdf(context, name, email),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
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
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _savePdf(context, name, email),
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

  Future<void> _savePdf(BuildContext context, String name, String email) async {
    final file = await _buildPdfFile(name, email);
    if (!context.mounted) return;
    
    // Share the generated PDF
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Bukti Pembayaran PiliHotel - ${booking.bookingCode}',
        subject: 'Invoice PiliHotel',
      ),
    );
  }

  Future<File> _buildPdfFile(String name, String email) async {
    final qrPayload = '${HttpClient.serverUrl}/api/bookings/${booking.bookingCode}/download-pdf';
    final document = pw.Document();

    final logoBytes = (await rootBundle.load('assets/images/logo.jpg')).buffer.asUint8List();
    final logoImage = pw.MemoryImage(logoBytes);

    final hotelName = booking.hotel?.name ?? hotel.name;
    final roomName = booking.room?.name ?? 'Deluxe King Suite';
    final hotelAndRoom = '$hotelName - $roomName';

    int extrasPrice = 0;
    if (booking.extras != null) {
      for (final extra in booking.extras!) {
        extrasPrice += _asInt(extra['price']);
      }
    }
    final basePrice = booking.totalPrice - extrasPrice;

    // Define colors
    final primaryBlue = PdfColor.fromHex('#2563EB');
    final textDark = PdfColor.fromHex('#1E293B');
    final textMuted = PdfColor.fromHex('#94A3B8');
    final borderLight = PdfColor.fromHex('#E2E8F0');

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Stack(
            children: [
              // LUNAS Watermark
              pw.Positioned.fill(
                child: pw.Center(
                  child: pw.Opacity(
                    opacity: 1.0,
                    child: pw.Transform.rotate(
                      angle: 0.45,
                      child: pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColor.fromHex('#E8FDF3'), width: 8),
                          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(20)),
                        ),
                        child: pw.Text(
                          'LUNAS',
                          style: pw.TextStyle(
                            color: PdfColor.fromHex('#E8FDF3'),
                            fontSize: 100,
                            fontWeight: pw.FontWeight.bold,
                            letterSpacing: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Main Content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Image(logoImage, width: 40, height: 40),
                          pw.SizedBox(width: 12),
                          pw.Text(
                            'PiliHotel',
                            style: pw.TextStyle(
                              fontSize: 24,
                              color: textDark,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'BUKTI PEMBAYARAN RESMI',
                            style: pw.TextStyle(
                              fontSize: 14,
                              color: textDark,
                              fontWeight: pw.FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          pw.SizedBox(height: 6),
                          pw.Text(
                            'INV/${booking.checkIn.year}${booking.checkIn.month.toString().padLeft(2, '0')}${booking.checkIn.day.toString().padLeft(2, '0')}/PH/${booking.bookingCode}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(color: borderLight, thickness: 1),
                  pw.SizedBox(height: 10),

                  // Informasi Pelanggan
                  _pdfSectionHeader('INFORMASI PELANGGAN', primaryBlue),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('NAMA PEMESAN', style: pw.TextStyle(color: textMuted, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 4),
                            pw.Text(name, style: pw.TextStyle(color: textDark, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('EMAIL', style: pw.TextStyle(color: textMuted, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                            pw.SizedBox(height: 4),
                            pw.Text(email, style: pw.TextStyle(color: textDark, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),

                  // Detail Reservasi
                  _pdfSectionHeader('DETAIL RESERVASI', primaryBlue),
                  pw.Container(
                    width: double.infinity,
                    padding: const pw.EdgeInsets.all(24),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('#F8FAFC'),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(16)),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('HOTEL & KAMAR', style: pw.TextStyle(color: textMuted, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 6),
                        pw.Text(hotelAndRoom, style: pw.TextStyle(color: textDark, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 20),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('CHECK-IN', style: pw.TextStyle(color: textMuted, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 6),
                                  pw.Text(_date(booking.checkIn), style: pw.TextStyle(color: textDark, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                            pw.Expanded(
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Text('DURASI', style: pw.TextStyle(color: textMuted, fontSize: 10, fontWeight: pw.FontWeight.bold)),
                                  pw.SizedBox(height: 6),
                                  pw.Text('${booking.nights} Malam', style: pw.TextStyle(color: textDark, fontSize: 14, fontWeight: pw.FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),

                  // Rincian Transaksi
                  _pdfSectionHeader('RINCIAN TRANSAKSI', primaryBlue),
                  pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Harga (${booking.nights} Malam)', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 12)),
                          pw.Text(_rupiah(basePrice), style: pw.TextStyle(color: textDark, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Layanan Tambahan (Add-ons)', style: pw.TextStyle(color: PdfColor.fromHex('#64748B'), fontSize: 12)),
                          pw.Text(_rupiah(extrasPrice), style: pw.TextStyle(color: textDark, fontSize: 12, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 16),
                      pw.Divider(color: borderLight, thickness: 1),
                      pw.SizedBox(height: 16),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL', style: pw.TextStyle(color: textDark, fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text(_rupiah(booking.totalPrice), style: pw.TextStyle(color: primaryBlue, fontSize: 24, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  pw.Spacer(),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Expanded(
                        child: pw.Padding(
                          padding: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Text(
                            'Dokumen sah dari sistem PiliHotel. Simpan sebagai\nbukti check-in.',
                            style: pw.TextStyle(color: textMuted, fontSize: 10, lineSpacing: 1.5),
                          ),
                        ),
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.BarcodeWidget(
                            barcode: pw.Barcode.qrCode(),
                            data: qrPayload,
                            width: 60,
                            height: 60,
                          ),
                          pw.SizedBox(height: 4),
                          pw.Text(
                            '#${booking.bookingCode}',
                            style: pw.TextStyle(color: textMuted, fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/PiliHotel-${booking.bookingCode}.pdf');
    await file.writeAsBytes(await document.save());
    return file;
  }

  pw.Widget _pdfSectionHeader(String title, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 24),
      child: pw.Row(
        children: [
          pw.Container(width: 30, height: 2, color: color),
          pw.SizedBox(width: 12),
          pw.Text(
            title,
            style: pw.TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
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
