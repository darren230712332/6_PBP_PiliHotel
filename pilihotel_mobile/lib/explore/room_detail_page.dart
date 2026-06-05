import 'package:flutter/material.dart';

import '../booking/booking_page.dart';
import '../core/colors.dart';
import '../core/models/review.dart' as api_review;
import '../core/widgets/hotel_card.dart';
import '../core/models/room.dart' as api;
import '../core/services/review_service.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/rating_widget.dart';

double _asDouble(dynamic value, [double defaultValue = 0.0]) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    return double.tryParse(value) ?? num.tryParse(value)?.toDouble() ?? defaultValue;
  }
  return defaultValue;
}

class RoomDetailPage extends StatelessWidget {
  RoomDetailPage({super.key, required this.hotel, required this.room});

  final UiHotel hotel;
  final api.Room room;
  final ReviewService _reviewService = ReviewService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Detail Kamar'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
        children: [
          SizedBox(
            height: 230,
            child: PageView(
              children: [
                for (final photo in (room.photos.isNotEmpty ? room.photos : [hotel.image]))
                  HotelImage(kind: photo, height: 230, width: double.infinity),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            room.name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 4),
          Text(
            hotel.name,
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
                icon: Icons.people_alt_outlined,
                label: '2',
                caption: 'Dewasa',
                onTap: () => _showInfo(context, 'Kapasitas 2 orang dewasa'),
              ),
              _Spec(
                icon: Icons.king_bed_outlined,
                label: '1',
                caption: 'King Bed',
                onTap: () => _showInfo(context, '1 kasur king tersedia'),
              ),
              _Spec(
                icon: Icons.square_foot_outlined,
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
            room.description ?? 'Kamar luas dengan pencahayaan hangat, kasur nyaman, kamar mandi privat, dan suasana tenang untuk istirahat maksimal.',
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
              for (final facility in (room.facilities ?? ['WiFi', 'AC', 'TV', 'Kopi']).take(4))
                _Facility(
                  icon: _facilityIcon(facility),
                  label: facility,
                  onTap: () => _showInfo(context, '$facility tersedia'),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ulasan Pengguna',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              GestureDetector(
                onTap: () => _showAllReviews(context),
                child: const Text(
                  'Lihat Semua Ulasan',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FutureBuilder<List<api_review.Review>>(
            future: _reviewService.getReviews(),
            builder: (context, snapshot) {
              final reviews = (snapshot.data ?? [])
                  .where((review) => review.roomId == room.id)
                  .toList();

              if (snapshot.connectionState == ConnectionState.waiting && reviews.isEmpty) {
                return const Center(child: Padding(
                  padding: EdgeInsets.all(18),
                  child: CircularProgressIndicator(),
                ));
              }

              return Column(children: _buildReviewCards(reviews));
            },
          ),
          const SizedBox(height: 24),
          const Text(
            'Lokasi',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(9),
              color: Colors.grey[200],
            ),
            child: Center(
              child: Icon(
                Icons.location_on_outlined,
                color: AppColors.primaryBlue,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppColors.primaryBlue,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  hotel.location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
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
              child: Text(
                  'Rp${room.pricePerNight}\n/malam',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
              ),
            ),
            Expanded(
              child: PrimaryButton(
                text: 'Pesan Sekarang',
                icon: Icons.arrow_forward,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookingPage(
                        hotel: UiHotel(
                          name: hotel.name,
                          location: hotel.location,
                          price: 'Rp${room.pricePerNight}',
                          rating: hotel.rating,
                          image: hotel.image,
                          distance: hotel.distance,
                        ),
                        roomId: room.id,
                      ),
                    ),
                  ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildReviewCards(List<api_review.Review> apiReviews) {
    final reviews = apiReviews.isNotEmpty
        ? apiReviews
            .map(
              (review) => {
                'name': 'Tamu PiliHotel',
                'rating': review.rating,
                'text': review.comment ?? 'Tamu belum menambahkan komentar.',
                'photos': review.photos ?? <String>[],
              },
            )
            .toList()
        : [
      {
        'name': 'Jane Doe',
        'rating': 4.8,
        'text':
            'Kamar nyaman, pelayanan ramah, dan pemandangan bagus. Puas dengan kualitas fasilitas.',
        'photos': <String>[],
      },
      {
        'name': 'Ahmad Riski',
        'rating': 4.5,
        'text':
            'Staf sangat puas menangani silhouetti. Lifewalking strategi, detail, ruang bersih. Sarapan lezat. Harga terjangkau. Akan datang lagi dengan keluarga',
        'photos': <String>[],
      },
      {
        'name': 'Joko Rina',
        'rating': 4.7,
        'text':
            'Pemandangan laut yang sunyi tidak menggangu, kamar dengan AC yang dingin. Pelayanan staff sangat memuaskan, sarapan enak, parkir luas.',
        'photos': <String>[],
      },
    ];

    return [
      for (int i = 0; i < reviews.length; i++) ...[
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .05),
                blurRadius: 12,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: Color(0xFFD8A15F),
                    child: Icon(Icons.person, size: 24, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reviews[i]['name'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RatingWidget(rating: _asDouble(reviews[i]['rating'])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                reviews[i]['text'] as String,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.45,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 10),
              _ReviewPhotos(photos: reviews[i]['photos'] as List<String>),
            ],
          ),
        ),
        if (i < reviews.length - 1) const SizedBox(height: 12),
      ],
    ];
  }

  void _showAllReviews(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const _AllReviewsPage(),
      ),
    );
  }

  void _showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }

  IconData _facilityIcon(String facility) {
    final value = facility.toLowerCase();
    if (value.contains('wifi')) return Icons.wifi;
    if (value.contains('ac')) return Icons.ac_unit;
    if (value.contains('tv')) return Icons.tv;
    if (value.contains('kopi') || value.contains('teh')) return Icons.local_cafe_outlined;
    if (value.contains('sarapan')) return Icons.restaurant_outlined;
    if (value.contains('kulkas')) return Icons.kitchen_outlined;
    return Icons.check_circle_outline;
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
        borderRadius: BorderRadius.circular(9),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.field,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primaryBlue),
              const SizedBox(height: 5),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
              Text(
                caption,
                style: const TextStyle(fontSize: 9, color: AppColors.muted),
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
    final visiblePhotos = photos.take(3).toList();

    if (visiblePhotos.isEmpty) {
      return Row(
        children: [
          _placeholder(),
          const SizedBox(width: 8),
          _placeholder(),
        ],
      );
    }

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
              errorBuilder: (context, error, stackTrace) => _placeholder(),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: Colors.grey[200],
      ),
    );
  }
}

class _AllReviewsPage extends StatelessWidget {
  const _AllReviewsPage();

  @override
  Widget build(BuildContext context) {
    final reviews = [
      {
        'name': 'Jane Doe',
        'rating': 4.8,
        'text':
            'Kamar nyaman, pelayanan ramah, dan pemandangan bagus. Puas dengan kualitas fasilitas.',
      },
      {
        'name': 'Ahmad Riski',
        'rating': 4.5,
        'text':
            'Staf sangat puas menangani silhouetti. Lifewalking strategi, detail, ruang bersih. Sarapan lezat. Harga terjangkau. Akan datang lagi dengan keluarga',
      },
      {
        'name': 'Joko Rina',
        'rating': 4.7,
        'text':
            'Pemandangan laut yang sunyi tidak menggangu, kamar dengan AC yang dingin. Pelayanan staff sangat memuaskan, sarapan enak, parkir luas.',
      },
      {
        'name': 'Siti Nurhaliza',
        'rating': 4.9,
        'text':
            'Pengalaman menginap yang luar biasa! Fasilitas lengkap, staf ramah, kamar bersih dan nyaman. Pasti akan datang lagi.',
      },
      {
        'name': 'Bambang Sutrisno',
        'rating': 4.6,
        'text': 'Lokasi strategis, harga terjangkau, pelayanan memuaskan. Cocok untuk liburan keluarga.',
      },
    ];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Semua Ulasan'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 22),
        children: [
          for (int i = 0; i < reviews.length; i++) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 18,
                        backgroundColor: Color(0xFFD8A15F),
                        child: Icon(Icons.person, size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviews[i]['name'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            RatingWidget(rating: _asDouble(reviews[i]['rating'])),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    reviews[i]['text'] as String,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.45,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[200],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.grey[200],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (i < reviews.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
