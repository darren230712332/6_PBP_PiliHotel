import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:qr_flutter/qr_flutter.dart';

import '../core/colors.dart';
import '../core/models/booking.dart' as api;
import '../core/widgets/bottom_navbar.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/primary_button.dart';

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

    return Scaffold(
      appBar: const CustomAppBar(title: 'Bukti Pembayaran (PDF)'),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .08),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PiliHotel',
                      style: TextStyle(
                        fontSize: 20,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'BUKTI PEMBAYARAN HOTEL',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.muted,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Divider(height: 30),
                    _row('Nomor Invoice', 'INV-${booking.bookingCode}'),
                    _row('ID Pesanan', booking.bookingCode),
                    _row('Nama Hotel', booking.hotel?.name ?? hotel.name),
                    _row('Kamar', booking.room?.name ?? 'Kamar'),
                    _row('Check-in', _date(booking.checkIn)),
                    _row('Check-out', _date(booking.checkOut)),
                    _row('Durasi', '${booking.nights} malam'),
                    _row('Metode Bayar', booking.paymentMethod ?? '-'),
                    const Divider(height: 28),
                    for (final extra in booking.extras ?? <Map<String, dynamic>>[])
                      _row(extra['name']?.toString() ?? 'Add-on', _rupiah(_asInt(extra['price']))),
                    _row('TOTAL', _rupiah(booking.totalPrice), bold: true),
                    const SizedBox(height: 18),
                    Center(
                      child: QrImageView(
                        data: qrPayload,
                        size: 118,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: Text(
                        qrPayload,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 9, color: AppColors.muted),
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Terima kasih telah memesan melalui PiliHotel.',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: 'Generate File PDF',
              icon: Icons.picture_as_pdf_outlined,
              onPressed: () => _savePdf(context),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1)),
                (_) => false,
              ),
              icon: const Icon(Icons.home_outlined, size: 16),
              label: const Text('Kembali ke Beranda'),
            ),
          ],
        ),
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

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: bold ? AppColors.text : AppColors.muted,
                fontWeight: bold ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: bold ? 13 : 11,
                color: bold ? AppColors.primaryBlue : AppColors.text,
                fontWeight: FontWeight.w900,
              ),
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
