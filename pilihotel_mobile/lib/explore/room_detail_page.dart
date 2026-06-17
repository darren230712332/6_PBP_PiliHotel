import 'package:flutter/material.dart';
import 'dart:math';

import '../booking/booking_page.dart';
import '../core/colors.dart';
import '../core/models/review.dart' as api_review;
import '../core/widgets/hotel_card.dart';
import '../core/models/room.dart' as api;
import '../core/services/review_service.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/primary_button.dart';

class RoomDetailPage extends StatefulWidget {
  const RoomDetailPage({super.key, required this.hotel, required this.room});

  final UiHotel hotel;
  final api.Room room;

  @override
  State<RoomDetailPage> createState() => _RoomDetailPageState();
}

class _RoomDetailPageState extends State<RoomDetailPage> {
  final ReviewService _reviewService = ReviewService();
  late Future<List<api_review.Review>> _reviewsFuture;
  bool _showAllReviews = false;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _reviewService.getReviews();
  }

  @override
  Widget build(BuildContext context) {
    final roomName = widget.room.name == 'Deluxe King Room'
        ? 'Deluxe King Suite'
        : widget.room.name;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Detail Kamar'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
        children: [
          SizedBox(
            height: 230,
            child: PageView(
              children: [
                for (final photo
                    in (widget.room.photos.isNotEmpty
                        ? widget.room.photos
                        : [widget.hotel.image]))
                  HotelImage(kind: photo, height: 230, width: double.infinity),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            roomName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            widget.hotel.name,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _Spec(
                icon: Icons.people_outline,
                label: '2',
                caption: 'Dewasa',
                onTap: () => _showInfo(context, 'Kapasitas 2 orang dewasa'),
              ),
              _Spec(
                icon: Icons.bed_outlined,
                label: '1',
                caption: 'Kamar Tidur',
                onTap: () => _showInfo(context, '1 kasur king tersedia'),
              ),
              _Spec(
                icon: Icons.bathtub_outlined,
                label: '1',
                caption: 'Kamar Mandi',
                onTap: () => _showInfo(context, '1 kamar mandi pribadi'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Deskripsi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            widget.room.description ??
                'Kamar luas dengan pencahayaan hangat, kasur nyaman, kamar mandi privat, dan suasana tenang untuk istirahat maksimal.',
            style: const TextStyle(
              fontSize: 12,
              height: 1.55,
              color: AppColors.muted,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Fasilitas',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              for (final facility
                  in (widget.room.facilities ?? ['WiFi', 'AC', 'TV', 'Kopi'])
                      .take(4))
                _Facility(
                  icon: _facilityIcon(facility),
                  label: _mapFacilityLabel(facility),
                  onTap: () => _showInfo(context, '$facility tersedia'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<api_review.Review>>(
            future: _reviewsFuture,
            builder: (context, snapshot) {
              final apiReviews = (snapshot.data ?? [])
                  .where((review) => review.roomId == widget.room.id)
                  .toList();
              final allReviews = _getAllReviews(apiReviews);

              final totalReviews = allReviews.length;
              final double avgRating = allReviews.isEmpty
                  ? 0.0
                  : allReviews.map((r) => r['rating'] as double).reduce((a, b) => a + b) / totalReviews;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Ulasan Pengguna',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                          const SizedBox(width: 3),
                          Text(
                            avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($totalReviews ulasan)',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (allReviews.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Text(
                          'Belum ada ulasan untuk kamar ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  else
                    ..._buildReviewCards(allReviews),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Lokasi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          _MockMapView(hotelName: widget.hotel.name),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  widget.hotel.location == 'Yogyakarta, Indonesia'
                      ? 'Jl. Babarsari No. 123, Sleman, Yogyakarta. 5 menit jalan kaki dari pusat perbelanjaan dan kampus utama.'
                      : widget.hotel.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
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
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HARGA PER MALAM',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'Rp${widget.room.pricePerNight.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (Match m) => "${m[1]}.")}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: AppColors.text,
                          ),
                        ),
                        const TextSpan(
                          text: ' /malam',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PrimaryButton(
                text: 'Pesan Sekarang',
                icon: Icons.arrow_forward,
                iconOnRight: true,
                onPressed: () {
                  final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
                  final formattedPrice =
                      'Rp${widget.room.pricePerNight.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        hotel: UiHotel(
                          name: widget.hotel.name,
                          location: widget.hotel.location,
                          price: formattedPrice,
                          rating: widget.hotel.rating,
                          image: widget.hotel.image,
                          distance: widget.hotel.distance,
                        ),
                        roomId: widget.room.id,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _mapFacilityLabel(String facility) {
    final lower = facility.toLowerCase();
    if (lower.contains('wifi')) return 'WiFi Gratis';
    if (lower == 'ac') return 'AC';
    if (lower.contains('tv')) return 'TV Pintar';
    if (lower.contains('kopi') || lower.contains('teh')) return 'Kopi';
    return facility;
  }

  IconData _facilityIcon(String facility) {
    final value = facility.toLowerCase();
    if (value.contains('wifi')) return Icons.wifi;
    if (value.contains('ac')) return Icons.ac_unit;
    if (value.contains('tv')) return Icons.tv;
    if (value.contains('kopi') || value.contains('teh'))
      return Icons.local_cafe_outlined;
    if (value.contains('sarapan')) return Icons.restaurant_outlined;
    if (value.contains('kulkas')) return Icons.kitchen_outlined;
    return Icons.check_circle_outline;
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  String _formatReviewDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        if (diff.inMinutes == 0) {
          return 'Baru saja';
        }
        return '${diff.inMinutes} menit yang lalu';
      }
      return '${diff.inHours} jam yang lalu';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} hari yang lalu';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  List<Map<String, dynamic>> _getAllReviews(List<api_review.Review> apiReviews) {
    final List<Map<String, dynamic>> allReviews = [];

    // Prepend API reviews
    for (final review in apiReviews) {
      allReviews.add({
        'name': review.userName ?? 'Tamu PiliHotel',
        'rating': review.rating.toDouble(),
        'text': review.comment ?? 'Tamu belum menambahkan komentar.',
        'photos': review.photos ?? <String>[],
        'date': _formatReviewDate(review.createdAt),
        'photo_url': review.userPhotoUrl,
      });
    }

    return allReviews;
  }

  List<Widget> _buildReviewCards(List<Map<String, dynamic>> allReviews) {
    final visibleReviews = _showAllReviews
        ? allReviews
        : allReviews.take(1).toList();

    return [
      for (int i = 0; i < visibleReviews.length; i++) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Builder(
                    builder: (context) {
                      final photoUrl = visibleReviews[i]['photo_url'] as String?;
                      final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

                      return Container(
                        width: 36,
                        height: 36,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEAF4FF),
                          shape: BoxShape.circle,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: hasPhoto
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Center(
                                  child: Text(
                                    _getInitials(visibleReviews[i]['name'] as String),
                                    style: const TextStyle(
                                      color: AppColors.primaryBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  _getInitials(visibleReviews[i]['name'] as String),
                                  style: const TextStyle(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visibleReviews[i]['name'] as String,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        visibleReviews[i]['date'] as String,
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        Icons.star_rounded,
                        color: index < (visibleReviews[i]['rating'] as num).round()
                            ? AppColors.warning
                            : Colors.grey[300],
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                visibleReviews[i]['text'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              _ReviewPhotos(
                photos: List<String>.from(visibleReviews[i]['photos'] as List),
              ),
            ],
          ),
        ),
        if (i < visibleReviews.length - 1) const SizedBox(height: 12),
      ],
      if (!_showAllReviews && allReviews.length > 1) ...[
        const SizedBox(height: 14),
        _buildExpandButton(),
      ] else if (_showAllReviews && allReviews.length > 1) ...[
        const SizedBox(height: 14),
        _buildCollapseButton(),
      ],
    ];
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty || parts[0].isEmpty) return 'U';
    if (parts.length == 1)
      return parts[0].substring(0, min(1, parts[0].length)).toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildExpandButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllReviews = true;
        });
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE7EEF7)),
        ),
        child: const Center(
          child: Text(
            'Baca Semua Ulasan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapseButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showAllReviews = false;
        });
      },
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFD),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE7EEF7)),
        ),
        child: const Center(
          child: Text(
            'Tutup Ulasan',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  const _Spec({
    required this.icon,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String caption;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryBlue, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                caption,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Facility extends StatelessWidget {
  const _Facility({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryBlue, size: 20),
            const SizedBox(height: 7),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewPhotos extends StatelessWidget {
  const _ReviewPhotos({required this.photos});

  final List<String> photos;

  @override
  Widget build(BuildContext context) {
    final visiblePhotos = photos.take(2).toList();

    if (visiblePhotos.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (final photo in visiblePhotos) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              photo,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(width: 50, height: 50, color: Colors.grey[200]),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _MockMapView extends StatelessWidget {
  const _MockMapView({required this.hotelName});

  final String hotelName;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: const Color(0xFFEBEAE6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0DFDA)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Stack(
          children: [
            // Vertical Road
            Positioned(
              left: 110,
              top: 0,
              bottom: 0,
              width: 34,
              child: Container(color: Colors.white),
            ),
            // Horizontal Road
            Positioned(
              left: 0,
              right: 0,
              top: 76,
              height: 34,
              child: Container(color: Colors.white),
            ),
            // Text: "JL. TEMBOK BAYAN"
            Positioned(
              left: 123,
              top: 10,
              child: RotatedBox(
                quarterTurns: 1,
                child: Text(
                  'JL. TEMBOK BAYAN',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
            // Text: "ABARSARI"
            Positioned(
              left: 154,
              top: 89,
              child: Text(
                'ABARSARI',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            // Card 1: Food Court (top right)
            Positioned(
              left: 164,
              top: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.restaurant, color: Colors.green, size: 10),
                    const SizedBox(width: 4),
                    Text(
                      'Food Court',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Card 2: Supermarket (bottom right)
            Positioned(
              left: 184,
              top: 124,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart,
                      color: Colors.orange,
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Supermarket',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Card 3: Puskesmas Transit (top left)
            Positioned(
              left: 28,
              top: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFD),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_hospital_outlined,
                      color: Colors.grey[400],
                      size: 10,
                    ),
                    const SizedBox(width: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Puskesmas',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Transit',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Blue pin in center (intersection) and white dot
            Positioned(
              left: 111,
              top: 114,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: AppColors.primaryBlue,
                    size: 36,
                  ),
                  Positioned(
                    top: 9,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Grand Palace Hotel blue badge
            Positioned(
              left: 68,
              top: 68,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  hotelName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Satellite button on bottom left
            Positioned(
              left: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  'PETA SATELIT AKTIF',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Target location button on top right
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  size: 14,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            // Zoom buttons on bottom right
            Positioned(
              right: 12,
              bottom: 48,
              child: Container(
                width: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 4),
                    const Icon(Icons.add, size: 14, color: Colors.grey),
                    Divider(height: 8, color: Colors.grey[200]),
                    const Icon(Icons.remove, size: 14, color: Colors.grey),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
            // Layers button on bottom right
            Positioned(
              right: 12,
              bottom: 12,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.layers_outlined,
                  size: 14,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
