import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/services/booking_service.dart';
import '../core/services/hotel_service.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/loading_dialog.dart';
import '../core/widgets/primary_button.dart';
import 'payment_page.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.hotel, this.roomId});

  final UiHotel hotel;
  final int? roomId;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final HotelService _hotelService = HotelService();
  final BookingService _bookingService = BookingService();
  DateTimeRange? stayRange;
  bool breakfast = false;
  bool massage = false;
  bool lateCheckout = false;
  bool _loading = false;

  int get nights {
    if (stayRange == null) return 0;
    return stayRange!.end.difference(stayRange!.start).inDays.clamp(1, 30);
  }

  int get roomTotal => _parsePrice(widget.hotel.price) * nights;
  int get extrasTotal =>
      (breakfast ? 50000 : 0) + (massage ? 100000 : 0) + (lateCheckout ? 75000 : 0);
  int get total => roomTotal + extrasTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detail Menginap'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 112),
        children: [
          Row(
            children: [
              const Text(
                'Pilih Tanggal',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              TextButton(
                onPressed: _pickStayRange,
                child: Text(
                  stayRange == null ? 'Pilih tanggal' : '$nights malam menginap',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          InkWell(
            onTap: _pickStayRange,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .06),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                children: [
                  _DateBox(
                    title: 'Check-in',
                    value: stayRange == null ? '-' : _date(stayRange!.start),
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.muted, size: 18),
                  _DateBox(
                    title: 'Check-out',
                    value: stayRange == null ? '-' : _date(stayRange!.end),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Tingkatkan Pengalaman Menginap',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _Option(
            title: 'Sarapan Premium Harian',
            subtitle: 'Sarapan lengkap untuk setiap hari menginap',
            price: 'Rp50.000',
            selected: breakfast,
            onTap: () => setState(() => breakfast = !breakfast),
          ),
          _Option(
            title: 'Pijat Tradisional',
            subtitle: 'Terapi relaksasi 60 menit di kamar hotel',
            price: 'Rp100.000',
            selected: massage,
            onTap: () => setState(() => massage = !massage),
          ),
          _Option(
            title: 'Late Check-out',
            subtitle: 'Tambah waktu check-out sampai sore',
            price: 'Rp75.000',
            selected: lateCheckout,
            onTap: () => setState(() => lateCheckout = !lateCheckout),
          ),
          const SizedBox(height: 18),
          _Summary(
            hotel: widget.hotel,
            nights: nights,
            roomTotal: roomTotal,
            extrasTotal: extrasTotal,
            total: total,
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: PrimaryButton(
          text: _loading ? 'Memproses...' : 'Bayar Sekarang',
          icon: Icons.credit_card,
          onPressed: _loading ? null : () => _createBookingAndPay(context),
        ),
      ),
    );
  }

  Future<void> _pickStayRange() async {
    final now = DateTime.now();
    final selected = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2),
      initialDateRange: stayRange,
      saveText: 'Pilih',
      helpText: 'Pilih tanggal menginap',
    );
    if (selected != null) {
      setState(() => stayRange = selected);
    }
  }

  Future<void> _createBookingAndPay(BuildContext context) async {
    if (stayRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal check-in dan check-out dulu.')),
      );
      return;
    }

    setState(() => _loading = true);
    await showPiliLoadingDialog(context, message: 'Mencari kamar dan membuat booking...');

    try {
      final hotels = await _hotelService.getHotels();
      final matchedHotel = hotels.firstWhere(
        (hotel) => hotel.name.toLowerCase() == widget.hotel.name.toLowerCase(),
        orElse: () => hotels.first,
      );

      final hotelDetail = await _hotelService.getHotelDetail(matchedHotel.id);
      final room = widget.roomId != null
          ? hotelDetail.rooms?.firstWhere((r) => r.id == widget.roomId, orElse: () => hotelDetail.rooms!.first)
          : hotelDetail.rooms?.isNotEmpty == true
              ? hotelDetail.rooms!.first
              : null;

      if (room == null) {
        throw Exception('Hotel ini belum memiliki kamar di backend.');
      }

      final extras = <Map<String, dynamic>>[
        if (breakfast) {'name': 'Sarapan Premium Harian', 'price': 50000},
        if (massage) {'name': 'Pijat Tradisional', 'price': 100000},
        if (lateCheckout) {'name': 'Late Check-out', 'price': 75000},
      ];

      final booking = await _bookingService.createBooking({
        'room_id': room.id,
        'check_in': _apiDate(stayRange!.start),
        'check_out': _apiDate(stayRange!.end),
        'extras': extras,
      });

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      showPaymentSheet(
        context,
        widget.hotel,
        total: booking.totalPrice,
        bookingId: booking.id,
      );
    } catch (e) {
      if (context.mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat booking: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  int _parsePrice(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digits) ?? 0;
  }

  String _apiDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  String _date(DateTime value) => '${value.day} ${_month(value.month)} ${value.year}';

  String _month(int month) {
    const names = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    return names[month - 1];
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.field,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: selected ? AppColors.primaryBlue : AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '$title\n$subtitle\n$price',
                style: const TextStyle(fontSize: 11, height: 1.45, fontWeight: FontWeight.w800),
              ),
            ),
            Icon(
              selected ? Icons.check_box : Icons.check_box_outline_blank,
              color: selected ? AppColors.primaryBlue : AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({
    required this.hotel,
    required this.nights,
    required this.roomTotal,
    required this.extrasTotal,
    required this.total,
  });

  final UiHotel hotel;
  final int nights;
  final int roomTotal;
  final int extrasTotal;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Booking',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          _miniRow('Hotel', hotel.name),
          _miniRow('Durasi', '$nights malam'),
          _miniRow('Kamar', _rupiah(roomTotal)),
          _miniRow('Add-on', _rupiah(extrasTotal)),
          _miniRow('Total', _rupiah(total)),
        ],
      ),
    );
  }

  Widget _miniRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(label, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
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
}
