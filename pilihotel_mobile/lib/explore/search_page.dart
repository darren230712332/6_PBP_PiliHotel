import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/models/hotel.dart' as api;
import '../core/services/hotel_service.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/hotel_card.dart';
import 'select_room_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final HotelService _hotelService = HotelService();
  final TextEditingController _searchController = TextEditingController();
  late final Future<List<api.Hotel>> _hotelsFuture = _hotelService.getHotels();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Cari hotel atau lokasi'),
      body: FutureBuilder<List<api.Hotel>>(
        future: _hotelsFuture,
        builder: (context, snapshot) {
          final hotels = snapshot.data ?? [];
          final query = _searchController.text.trim().toLowerCase();
          final filteredHotels = query.isEmpty
              ? hotels
              : hotels
                  .where(
                    (hotel) =>
                        hotel.name.toLowerCase().contains(query) ||
                        hotel.location.toLowerCase().contains(query),
                  )
                  .toList();

          if (snapshot.connectionState == ConnectionState.waiting && hotels.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.field,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Grand Palace Hotel',
                        ),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pencarian Terakhir',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _searchController.clear()),
                    child: const Text(
                      'HAPUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final hotel in filteredHotels.take(3))
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectRoomPage(hotel: _toUiHotel(hotel)),
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 9),
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
                    child: Row(
                      children: [
                        const Icon(
                          Icons.history,
                          color: AppColors.primaryBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hotel.location,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const Text(
                'REKOMENDASI EKSKLUSIF',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  children: [
                    for (final hotel in filteredHotels.take(3))
                      _ExclusiveRecommendationCard(
                        hotel: _toUiHotel(hotel),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SelectRoomPage(hotel: _toUiHotel(hotel)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Rekomendasi Untuk Anda',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              for (final hotel in filteredHotels)
                HotelCard(
                  hotel: _toUiHotel(hotel),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectRoomPage(hotel: _toUiHotel(hotel)),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  UiHotel _toUiHotel(api.Hotel hotel) {
    return UiHotel(
      name: hotel.name,
      location: hotel.location,
      price: 'Rp${hotel.pricePerNight}',
      rating: hotel.rating,
      image: hotel.image,
      distance: hotel.distance,
    );
  }
}

class _ExclusiveRecommendationCard extends StatelessWidget {
  const _ExclusiveRecommendationCard({
    required this.hotel,
    required this.onTap,
  });

  final UiHotel hotel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        width: 200,
        height: 160,
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            HotelImage(
              kind: hotel.image,
              height: 160,
              width: 200,
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: .6),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Promo Hari Ini',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: .9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '30% OFF',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
