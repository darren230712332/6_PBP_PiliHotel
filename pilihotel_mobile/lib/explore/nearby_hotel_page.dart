import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/models/hotel.dart' as api;
import '../core/services/hotel_service.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/rating_widget.dart';
import '../location/location_service.dart';
import 'select_room_page.dart';

class NearbyHotelPage extends StatefulWidget {
  const NearbyHotelPage({super.key});

  @override
  State<NearbyHotelPage> createState() => _NearbyHotelPageState();
}

class _NearbyHotelPageState extends State<NearbyHotelPage> {
  final HotelService _hotelService = HotelService();
  final LocationService _locationService = LocationService();
  late final Future<_NearbyHotelResult> _nearbyHotelsFuture = _loadNearbyHotels();

  Future<_NearbyHotelResult> _loadNearbyHotels() async {
    final location = await _locationService.currentLocation();
    final hotels = await _hotelService.getHotels();

    final items = hotels.map((hotel) {
      final hotelLatitude = hotel.latitude ?? location.latitude;
      final hotelLongitude = hotel.longitude ?? location.longitude;
      final distanceKm = _locationService.distanceKm(
        fromLatitude: location.latitude,
        fromLongitude: location.longitude,
        toLatitude: hotelLatitude,
        toLongitude: hotelLongitude,
      );

      return _NearbyHotelItem(
        hotel: hotel,
        distanceKm: distanceKm,
      );
    }).toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));

    return _NearbyHotelResult(location: location, items: items);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Hotel Terdekat'),
      body: FutureBuilder<_NearbyHotelResult>(
        future: _nearbyHotelsFuture,
        builder: (context, snapshot) {
          final nearbyHotels = snapshot.data?.items ?? [];

          if (snapshot.connectionState == ConnectionState.waiting && nearbyHotels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && nearbyHotels.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Gagal memuat hotel terdekat: ${snapshot.error}'),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 96),
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFEAF4FF),
                      child: Icon(
                        Icons.my_location,
                        color: AppColors.primaryBlue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'LOKASI SAAT INI',
                            style: TextStyle(
                              color: AppColors.muted,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            snapshot.data?.location.label ?? 'Mendeteksi lokasi...',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.tune_rounded, color: AppColors.muted, size: 18),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              for (final item in nearbyHotels)
                _NearbyHotelCard(
                  hotel: item.toUiHotel(),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectRoomPage(hotel: item.toUiHotel()),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _NearbyHotelResult {
  const _NearbyHotelResult({required this.location, required this.items});

  final UserLocation location;
  final List<_NearbyHotelItem> items;
}

class _NearbyHotelItem {
  const _NearbyHotelItem({required this.hotel, required this.distanceKm});

  final api.Hotel hotel;
  final double distanceKm;

  UiHotel toUiHotel() {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formattedPrice = 'Rp${hotel.pricePerNight.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
    return UiHotel(
      name: hotel.name,
      location: hotel.location,
      price: formattedPrice,
      rating: hotel.rating,
      image: hotel.image,
      distance: _formatDistance(distanceKm),
    );
  }

  String _formatDistance(double value) {
    if (value < 1) {
      return '${(value * 1000).round()} m';
    }
    return '${value.toStringAsFixed(value >= 10 ? 0 : 1)} km';
  }
}

class _NearbyHotelCard extends StatelessWidget {
  const _NearbyHotelCard({required this.hotel, required this.onTap});
  final UiHotel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HotelImage(kind: hotel.image, height: 258, width: double.infinity),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hotel.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me,
                            color: AppColors.primaryBlue,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${hotel.distance} dari lokasimu',
                            style: const TextStyle(
                              color: AppColors.primaryBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5D8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: RatingWidget(rating: hotel.rating, size: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.wifi, color: AppColors.success, size: 16),
                const SizedBox(width: 8),
                const Icon(
                  Icons.restaurant,
                  color: Color(0xFFFF7A1A),
                  size: 16,
                ),
                const Spacer(),
                Text(
                  hotel.price,
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Text(
                  '/mlm',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
