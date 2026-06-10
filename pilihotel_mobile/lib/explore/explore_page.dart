import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../core/colors.dart';
import '../core/models/hotel.dart' as api;
import '../core/services/hotel_service.dart';
import '../core/widgets/custom_dialog.dart';
import '../core/widgets/hotel_card.dart';
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
  Future<UserLocation>? _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = _locationService.currentLocation();
  }

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

  String _formatPrice(int price) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp${price.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  /// Transform API Hotel objects to UI Hotel objects
  List<UiHotel> _transformHotels(List<api.Hotel> apiHotels) {
    return apiHotels
        .map(
          (hotel) => UiHotel(
            name: hotel.name,
            location: hotel.location,
            price: _formatPrice(hotel.pricePerNight),
            rating: hotel.rating,
            image: _mapHotelImageKey(hotel.name, hotel.image),
            distance: hotel.distance,
          ),
        )
        .toList();
  }

  String _mapHotelImageKey(String hotelName, String originalKey) {
    if (hotelName.contains('Grand Palace')) return 'sea';
    if (hotelName.contains('Urban Stay')) return 'modern';
    if (hotelName.contains('Sea Breeze')) return 'pool';
    if (hotelName.contains('The Heritage') || hotelName.contains('Heritage')) return 'corridor';
    return originalKey;
  }

  /// Build the main hotel list view
  Widget _buildHotelList(BuildContext context, List<UiHotel> hotels) {
    final featuredHotels = <UiHotel>[];
    final popularHotels = <UiHotel>[];

    if (hotels.isNotEmpty) {
      final grandPalace = hotels.firstWhere((h) => h.name.contains('Grand Palace'), orElse: () => hotels[0]);
      final urbanStay = hotels.firstWhere((h) => h.name.contains('Urban Stay'), orElse: () => hotels.length > 1 ? hotels[1] : hotels[0]);
      final seaBreeze = hotels.firstWhere((h) => h.name.contains('Sea Breeze'), orElse: () => hotels.length > 2 ? hotels[2] : hotels[0]);
      final heritage = hotels.firstWhere((h) => h.name.contains('The Heritage') || h.name.contains('Heritage'), orElse: () => hotels.length > 3 ? hotels[3] : hotels[0]);

      featuredHotels.addAll([grandPalace, urbanStay]);
      popularHotels.addAll([seaBreeze, heritage]);
    }

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
        _buildFeaturedHotels(context, featuredHotels),
        const SizedBox(height: 22),
        const _SectionTitle(title: 'Hotel Populer'),
        const SizedBox(height: 14),
        _buildPopularHotels(context, popularHotels),
      ],
    );
  }

  /// Build top bar with logo and notification icon
  Widget _buildTopBar() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/images/logo.jpg',
            width: 32,
            height: 32,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'PiliHotel',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.primaryBlue,
          ),
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
                Text(
                  locationLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.muted,
                  size: 20,
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
          width: 54,
          height: 54,
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
            onPressed: () => _handleLocationButtonPressed(context),
            icon: const Icon(
              Icons.location_on_outlined,
              color: Colors.white,
              size: 22,
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
          for (final hotel in hotels)
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
        for (final hotel in hotels)
          _PopularHotelCard(
            hotel: hotel,
            distance: hotel.distance,
            reviewCount: hotel.name.contains('Sea Breeze') ? '1.2rb' : '850',
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

  Future<void> _handleLocationButtonPressed(BuildContext context) async {
    final currentPermission = await Geolocator.checkPermission();
    final isGranted = currentPermission == LocationPermission.always || 
                      currentPermission == LocationPermission.whileInUse;

    LocationPermission? finalPermission;

    if (!isGranted) {
      if (!context.mounted) return;
      finalPermission = await showCustomLocationPermissionDialog(context);
    } else {
      finalPermission = currentPermission;
    }

    if (finalPermission == null) return;

    if (finalPermission == LocationPermission.always || 
        finalPermission == LocationPermission.whileInUse) {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        if (!context.mounted) return;
        showPiliDialog(
          context,
          icon: Icons.location_off_outlined,
          title: 'Layanan Lokasi Mati',
          message: 'Silakan aktifkan layanan lokasi (GPS) pada perangkat Anda.',
          buttonText: 'Pengaturan',
          onPressed: () async {
            Navigator.pop(context);
            await Geolocator.openLocationSettings();
          },
          color: AppColors.warning,
        );
        return;
      }

      if (!mounted) return;
      setState(() {
        _locationFuture = _locationService.currentLocation();
      });
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NearbyHotelPage()),
        );
      }
    } else if (finalPermission == LocationPermission.deniedForever) {
      if (!context.mounted) return;
      showPiliDialog(
        context,
        icon: Icons.location_off_outlined,
        title: 'Izin Lokasi Ditolak Permanen',
        message: 'Aplikasi memerlukan izin lokasi. Silakan aktifkan di pengaturan aplikasi.',
        buttonText: 'Pengaturan',
        onPressed: () async {
          Navigator.pop(context);
          await Geolocator.openAppSettings();
        },
        color: AppColors.warning,
      );
    } else {
      if (!context.mounted) return;
      showPiliDialog(
        context,
        icon: Icons.location_off_outlined,
        title: 'Izin Lokasi Ditolak',
        message: 'Aplikasi memerlukan izin lokasi Anda untuk mencari hotel terdekat.',
        buttonText: 'Tutup',
        color: AppColors.warning,
      );
    }
  }
}

Future<LocationPermission?> showCustomLocationPermissionDialog(BuildContext context) {
  return showDialog<LocationPermission>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFEAF4FF),
                child: Icon(
                  Icons.location_on,
                  color: AppColors.primaryBlue,
                  size: 28,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Izinkan PiliHotel mengakses lokasi perangkat ini?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1E293B),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Kami menggunakan lokasi Anda untuk menemukan hotel terdekat dan memberikan penawaran terbaik di sekitar Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(double.infinity, 120),
                        painter: _MapGridPainter(),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0F52BA),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _dialogDivider(),
              _dialogButton(
                text: 'Saat Aplikasi Digunakan',
                color: AppColors.primaryBlue,
                bold: true,
                onTap: () async {
                  try {
                    final permission = await Geolocator.requestPermission();
                    if (context.mounted) {
                      Navigator.pop(context, permission);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      Navigator.pop(context, LocationPermission.denied);
                    }
                  }
                },
              ),
              _dialogDivider(),
              _dialogButton(
                text: 'Hanya Sekali',
                color: const Color(0xFF475569),
                bold: false,
                onTap: () async {
                  try {
                    final permission = await Geolocator.requestPermission();
                    if (context.mounted) {
                      Navigator.pop(context, permission);
                    }
                  } catch (_) {
                    if (context.mounted) {
                      Navigator.pop(context, LocationPermission.denied);
                    }
                  }
                },
              ),
              _dialogDivider(),
              _dialogButton(
                text: 'Jangan Izinkan',
                color: const Color(0xFFDC2626),
                bold: false,
                onTap: () {
                  Navigator.pop(context, LocationPermission.denied);
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _dialogDivider() {
  return Container(
    height: 1,
    width: double.infinity,
    color: const Color(0xFFF1F5F9),
  );
}

Widget _dialogButton({
  required String text,
  required Color color,
  required bool bold,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    ),
  );
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(0, size.height * 0.4), Offset(size.width, size.height * 0.5), paint);
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.4, size.height), paint);
    canvas.drawLine(Offset(size.width * 0.7, 0), Offset(size.width * 0.6, size.height), paint);
    canvas.drawLine(Offset(0, size.height * 0.75), Offset(size.width, size.height * 0.7), paint);
    canvas.drawLine(Offset(0, size.height * 0.15), Offset(size.width, size.height * 0.1), paint);
    canvas.drawLine(Offset(size.width * 0.1, 0), Offset(size.width * 0.2, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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
              HotelImage(
                kind: hotel.image,
                height: 168,
                width: width,
                borderRadius: BorderRadius.circular(16),
              ),
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
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFFFFB84D),
                          size: 13,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          hotel.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFB84D),
                          ),
                        ),
                      ],
                    ),
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
          border: Border.all(color: const Color(0xFFF1F3F6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            HotelImage(
              kind: hotel.image,
              height: 88,
              width: 98,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Text(
                        'Yogyakarta, Indonesia',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        ' • ',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        '${hotel.rating}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '($reviewCount ulasan)',
                        style: const TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                      const Spacer(),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: hotel.price,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                            const TextSpan(
                              text: '/mlm',
                              style: TextStyle(
                                fontSize: 9.5,
                                color: AppColors.muted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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


