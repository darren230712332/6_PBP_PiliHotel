import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String _selectedPaymentMethod = 'bank';
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    // Default stay range: today to 2 days later
    final now = DateTime.now();
    stayRange = DateTimeRange(
      start: DateTime(now.year, now.month, now.day),
      end: DateTime(now.year, now.month, now.day).add(const Duration(days: 2)),
    );
    _focusedMonth = DateTime(now.year, now.month, 1);
  }

  int get nights {
    if (stayRange == null) return 0;
    return stayRange!.end.difference(stayRange!.start).inDays.clamp(1, 30);
  }

  int get roomTotal => _parsePrice(widget.hotel.price) * nights;
  int get extrasTotal =>
      (breakfast ? 50000 : 0) +
      (massage ? 100000 : 0) +
      (lateCheckout ? 75000 : 0);
  int get total => roomTotal + extrasTotal;

  void _prevMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 1);
    });
  }

  void _onDayTapped(DateTime day) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (day.isBefore(today)) return;

    setState(() {
      if (stayRange == null || stayRange!.start != stayRange!.end) {
        stayRange = DateTimeRange(start: day, end: day);
      } else {
        if (day.isBefore(stayRange!.start)) {
          stayRange = DateTimeRange(start: day, end: day);
        } else {
          stayRange = DateTimeRange(start: stayRange!.start, end: day);
        }
      }
    });
  }

  List<DateTime> _generateCalendarDays(DateTime month) {
    final firstDay = DateTime(month.year, month.month, 1);
    final prevMonthLastDay = DateTime(month.year, month.month, 0);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    // Sunday starts week. In Dart, 7 is Sunday.
    final int startWeekday = firstDay.weekday == 7 ? 0 : firstDay.weekday;

    final List<DateTime> days = [];

    // Prev month padding
    for (int i = startWeekday - 1; i >= 0; i--) {
      days.add(DateTime(month.year, month.month - 1, prevMonthLastDay.day - i));
    }

    // Current month days
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(month.year, month.month, i));
    }

    // Next month padding to make exactly 42 grid items (6 weeks)
    final remainingCells = 42 - days.length;
    for (int i = 1; i <= remainingCells; i++) {
      days.add(DateTime(month.year, month.month + 1, i));
    }

    return days;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detail Menginap'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 180),
        children: [
          // Pilih Tanggal Section
          Row(
            children: [
              const Text(
                'Pilih Tanggal',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stayRange == null
                      ? 'Pilih Tanggal'
                      : '$nights Malam Terpilih',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Inline Calendar Widget Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _buildMonthHeader(),
                const SizedBox(height: 12),
                _buildWeekHeaders(),
                const SizedBox(height: 8),
                _buildCalendarGrid(),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Tingkatkan Pengalaman Menginap Section
          const Text(
            'Tingkatkan Pengalaman Menginap',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 10),
          _Option(
            title: 'Sarapan Prasmanan Harian',
            subtitle: 'Hidangan lokal dan internasional yang segar',
            price: 'Rp 50.000 / orang',
            selected: breakfast,
            onTap: () => setState(() => breakfast = !breakfast),
          ),
          _Option(
            title: 'Pijat Tradisional',
            subtitle: 'Terapi tubuh relaksasi selama 60 menit',
            price: 'Rp 100.000 / sesi',
            selected: massage,
            onTap: () => setState(() => massage = !massage),
          ),
          _Option(
            title: 'Check-out Terlambat',
            subtitle: 'Menginap hingga jam 16:00 pada hari keberangkatan',
            price: 'Rp 75.000',
            selected: lateCheckout,
            onTap: () => setState(() => lateCheckout = !lateCheckout),
          ),

          // Testimonial Section
          _buildTestimonialSection(),

          // Payment Methods Section
          _buildPaymentMethods(),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Subtotal Menginap ($nights malam)',
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  _rupiah(roomTotal),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
            if (extrasTotal > 0) ...[
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Layanan Tambahan',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    _rupiah(extrasTotal),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            const Divider(color: AppColors.border, height: 1),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Keseluruhan',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
                Text(
                  _rupiah(total),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              text: _loading ? 'Memproses...' : 'Bayar Sekarang',
              icon: Icons.account_balance_wallet_outlined,
              onPressed: _loading ? null : () => _createBookingAndPay(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.text, size: 18),
          onPressed: _prevMonth,
        ),
        Text(
          '${_monthName(_focusedMonth.month)} ${_focusedMonth.year}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.chevron_right,
            color: AppColors.text,
            size: 18,
          ),
          onPressed: _nextMonth,
        ),
      ],
    );
  }

  Widget _buildWeekHeaders() {
    final weekdays = ['M', 'S', 'S', 'R', 'K', 'J', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((label) {
        return Expanded(
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final days = _generateCalendarDays(_focusedMonth);
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1.1,
      ),
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final isCurrentMonth = day.month == _focusedMonth.month;
        return _buildDayCell(day, isCurrentMonth);
      },
    );
  }

  Widget _buildDayCell(DateTime day, bool isCurrentMonth) {
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final isPast = day.isBefore(today);

    final isStart =
        stayRange != null && DateUtils.isSameDay(day, stayRange!.start);
    final isEnd = stayRange != null && DateUtils.isSameDay(day, stayRange!.end);
    final isBetween =
        stayRange != null &&
        day.isAfter(stayRange!.start) &&
        day.isBefore(stayRange!.end);

    Color textColor = isCurrentMonth
        ? AppColors.text
        : AppColors.muted.withValues(alpha: 0.5);
    if (isStart || isEnd) {
      textColor = Colors.white;
    } else if (isBetween) {
      textColor = AppColors.primaryBlue;
    }

    Widget? rangeBackground;
    if (stayRange != null && stayRange!.start != stayRange!.end) {
      if (isStart) {
        rangeBackground = Row(
          children: [
            const Expanded(child: SizedBox()),
            Expanded(
              child: Container(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
              ),
            ),
          ],
        );
      } else if (isEnd) {
        rangeBackground = Row(
          children: [
            Expanded(
              child: Container(
                color: AppColors.primaryBlue.withValues(alpha: 0.12),
              ),
            ),
            const Expanded(child: SizedBox()),
          ],
        );
      } else if (isBetween) {
        rangeBackground = Container(
          color: AppColors.primaryBlue.withValues(alpha: 0.12),
        );
      }
    }

    return GestureDetector(
      onTap: isPast ? null : () => _onDayTapped(day),
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        child: Stack(
          children: [
            if (rangeBackground != null)
              Positioned.fill(child: rangeBackground),
            Center(
              child: Container(
                width: 28,
                height: 28,
                decoration: (isStart || isEnd)
                    ? const BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                      )
                    : null,
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isPast
                        ? AppColors.muted.withValues(alpha: 0.35)
                        : textColor,
                    fontWeight: (isStart || isEnd || isBetween)
                        ? FontWeight.bold
                        : FontWeight.w500,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Apa kata tamu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.text,
              ),
            ),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Lihat semua',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    const Icon(
                      Icons.star,
                      color: Color(0xFFF2994A), // Orange/Gold
                      size: 13,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '"Layanan tambahan pijat benar-benar sebanding. Cara sempurna untuk mengakhiri hari!"',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.muted,
                  height: 1.45,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const CircleAvatar(
                    radius: 10,
                    backgroundColor: AppColors.primaryBlue,
                    child: Text(
                      'SM',
                      style: TextStyle(
                        fontSize: 7,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Sarah Miller',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 22),
        const Text(
          'Metode Pembayaran',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        _buildPaymentCard(
          id: 'bank',
          title: 'Transfer Bank',
          icon: Icons.account_balance_outlined,
        ),
        _buildPaymentCard(
          id: 'card',
          title: 'Kartu Kredit/Debit',
          icon: Icons.credit_card_outlined,
        ),
        _buildPaymentCard(
          id: 'wallet',
          title: 'E-Wallet',
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }

  Widget _buildPaymentCard({
    required String id,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedPaymentMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = id),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryBlue : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio Button
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : AppColors.muted,
                  width: isSelected ? 5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: AppColors.primaryBlue, size: 18),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createBookingAndPay(BuildContext context) async {
    if (stayRange == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih tanggal check-in dan check-out dulu.'),
        ),
      );
      return;
    }

    setState(() => _loading = true);
    showPiliLoadingDialog(
      context,
      message: 'Mencari kamar dan membuat booking...',
    );

    try {
      int? finalRoomId = widget.roomId;

      if (finalRoomId == null) {
        debugPrint(
          'DEBUG_BOOKING: roomId is null, searching hotel and room details...',
        );
        final hotels = await _hotelService.getHotels();
        final matchedHotel = hotels.firstWhere(
          (hotel) =>
              hotel.name.toLowerCase() == widget.hotel.name.toLowerCase(),
          orElse: () => hotels.first,
        );

        final hotelDetail = await _hotelService.getHotelDetail(matchedHotel.id);
        final room = hotelDetail.rooms?.isNotEmpty == true
            ? hotelDetail.rooms!.first
            : null;

        if (room == null) {
          throw Exception('Hotel ini belum memiliki kamar di backend.');
        }
        finalRoomId = room.id;
      }

      debugPrint('DEBUG_BOOKING: Using room ID: $finalRoomId');

      final extras = <Map<String, dynamic>>[
        if (breakfast) {'name': 'Sarapan Premium Harian', 'price': 50000},
        if (massage) {'name': 'Pijat Tradisional', 'price': 100000},
        if (lateCheckout) {'name': 'Late Check-out', 'price': 75000},
      ];

      debugPrint('DEBUG_BOOKING: Creating booking on backend...');
      final booking = await _bookingService.createBooking({
        'room_id': finalRoomId,
        'check_in': _apiDate(stayRange!.start),
        'check_out': _apiDate(stayRange!.end),
        'extras': extras,
      });
      debugPrint(
        'DEBUG_BOOKING: Booking created successfully. Booking ID: ${booking.id}',
      );

      try {
        final prefs = await SharedPreferences.getInstance();
        final list = prefs.getStringList('simulated_completed_bookings') ?? [];
        if (list.contains(booking.id.toString())) {
          list.remove(booking.id.toString());
          await prefs.setStringList('simulated_completed_bookings', list);
        }
      } catch (_) {}

      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      debugPrint('DEBUG_BOOKING: Showing payment sheet...');
      showPaymentSheet(
        context,
        widget.hotel,
        total: booking.totalPrice,
        bookingId: booking.id,
      );
    } catch (e) {
      debugPrint('DEBUG_BOOKING: Error caught: $e');
      if (context.mounted &&
          Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal membuat booking: $e')));
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

  String _monthName(int month) {
    const names = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
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
    return 'Rp $buffer';
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
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: AppColors.muted,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Custom Checkbox
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryBlue : Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: selected ? AppColors.primaryBlue : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
