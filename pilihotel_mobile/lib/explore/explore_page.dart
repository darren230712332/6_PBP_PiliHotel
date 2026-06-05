import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/models/hotel.dart' as api;
import '../core/services/hotel_service.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/logo.dart';
import '../core/widgets/rating_widget.dart';
import '../location/location_service.dart';
import 'select_room_page.dart';
import 'nearby_hotel_page.dart';
import 'search_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final HotelService _hotelService = HotelService();
  final LocationService _locationService = LocationService();
  late final Future<List<api.Hotel>> _hotelsFuture = _hotelService.getHotels();
  late final Future<UserLocation> _locationFuture = _locationService.currentLocation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<List<api.Hotel>>(
          future: _hotelsFuture,
          builder: (context, snapshot) {
            // Handle different states of the FutureBuilder
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat hotel',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }

            // Transform API hotels to UI hotels
            final apiHotels = snapshot.data ?? [];
            final mappedHotels = _transformHotels(apiHotels);

            if (mappedHotels.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.hotel_outlined,
                        size: 48,
                        color: AppColors.muted,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Tidak ada hotel tersedia',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              );
            }

            return _buildHotelList(context, mappedHotels);
          },
        ),
      ),
    );
  }

  /// Transform API Hotel objects to UI Hotel objects
  List<UiHotel> _transformHotels(List<api.Hotel> apiHotels) {
    return apiHotels
        .map(
          (hotel) => UiHotel(
            name: hotel.name,
            location: hotel.location,
            price: 'Rp${hotel.pricePerNight}',
            rating: hotel.rating,
            image: hotel.image,
            distance: hotel.distance,
          ),
        )
        .toList();
  }

  /// Build the main hotel list view
  Widget _buildHotelList(BuildContext context, List<UiHotel> hotels) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 26, 22, 96),
      children: [
        _buildTopBar(),
        const SizedBox(height: 26),
        _buildLocationSection(),
        const SizedBox(height: 16),
        _buildSearchBar(context),
        const SizedBox(height: 34),
        const _SectionTitle(title: 'Rekomendasi Hotel'),
        const SizedBox(height: 16),
        _buildFeaturedHotels(context, hotels),
        const SizedBox(height: 22),
        const _SectionTitle(title: 'Hotel Populer'),
        const SizedBox(height: 14),
        _buildPopularHotels(context, hotels),
      ],
    );
  }

  /// Build top bar with logo and notification icon
  Widget _buildTopBar() {
    return Row(
      children: [
        const PiliLogo(
          size: 28,
          showText: true,
          textColor: AppColors.primaryBlue,
        ),
        const Spacer(),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: Color(0xFFF2F6FB),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              size: 22,
              color: AppColors.text,
            ),
          ),
        ),
      ],
    );
  }

  /// Build current location section
  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LOKASI SAAT INI',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        FutureBuilder<UserLocation>(
          future: _locationFuture,
          builder: (context, locationSnapshot) {
            final locationLabel =
                locationSnapshot.data?.label ?? 'Mendeteksi lokasi...';
            return Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 22,
                  color: AppColors.primaryBlue,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    locationLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.muted,
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// Build search bar and filter button
  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchPage()),
            ),
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: AppColors.muted, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Cari nama hotel atau lokasi',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.muted,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: .28),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => _showLocationPermission(context),
            icon: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  /// Build featured hotels horizontal carousel
  Widget _buildFeaturedHotels(BuildContext context, List<UiHotel> hotels) {
    return SizedBox(
      height: 238,
      child: ListView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        children: [
          for (final hotel in hotels.take(3))
            _FeaturedHotelCard(
              hotel: hotel,
              width: 224,
              onTap: () => _openDetail(context, hotel),
            ),
        ],
      ),
    );
  }

  /// Build popular hotels vertical list
  Widget _buildPopularHotels(BuildContext context, List<UiHotel> hotels) {
    return Column(
      children: [
        for (final hotel in hotels.take(2))
          _PopularHotelCard(
            hotel: hotel,
            distance: hotel.distance,
            reviewCount: '${(hotel.rating * 250).round()}',
            onTap: () => _openDetail(context, hotel),
          ),
      ],
    );
  }

  void _openDetail(BuildContext context, UiHotel hotel) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SelectRoomPage(hotel: hotel)),
    );
  }

  Future<void> _showLocationPermission(BuildContext context) async {
    final granted = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: .45),
      builder: (_) => const _LocationPermissionDialog(),
    );

    if (granted == true && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NearbyHotelPage()),
      );
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }
}

class _FeaturedHotelCard extends StatelessWidget {
  const _FeaturedHotelCard({
    required this.hotel,
    required this.width,
    required this.onTap,
  });

  final UiHotel hotel;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HotelImage(kind: hotel.image, height: 168, width: width),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      hotel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
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
              const SizedBox(height: 5),
              Text(
                hotel.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularHotelCard extends StatelessWidget {
  const _PopularHotelCard({
    required this.hotel,
    required this.distance,
    required this.reviewCount,
    required this.onTap,
  });

  final UiHotel hotel;
  final String distance;
  final String reviewCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            HotelImage(kind: hotel.image, height: 88, width: 98),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    hotel.location,
                    style: const TextStyle(fontSize: 10, color: AppColors.muted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$distance • $reviewCount ulasan',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF5D8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: RatingWidget(rating: hotel.rating, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationPermissionDialog extends StatelessWidget {
  const _LocationPermissionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFFEAF4FF),
              child: Icon(Icons.location_on_outlined, color: AppColors.primaryBlue, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              'Izinkan akses lokasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Kami akan mencari hotel yang paling dekat dari posisi Anda saat ini.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.45),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Batal'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Izinkan'),
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
