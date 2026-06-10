import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/models/hotel.dart' as api;
import '../core/services/hotel_service.dart';
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.text, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppColors.muted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Cari hotel atau lokasi',
                          hintStyle: TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                          isDense: true,
                        ),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF1F3F6),
            height: 1,
          ),
        ),
      ),
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
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 96),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pencarian Terakhir',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.text,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _searchController.clear()),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Text(
                        'HAPUS',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < filteredHotels.take(3).length; i++) ...[
                Builder(
                  builder: (context) {
                    final hotel = filteredHotels[i];
                    late final IconData leadingIcon;
                    late final Color leadingBg;
                    late final Color leadingColor;

                    if (i == 0) {
                      leadingIcon = Icons.history;
                      leadingBg = const Color(0xFFEAF4FF);
                      leadingColor = AppColors.primaryBlue;
                    } else if (i == 1) {
                      leadingIcon = Icons.location_on_outlined;
                      leadingBg = const Color(0xFFF1F5F9);
                      leadingColor = AppColors.muted;
                    } else {
                      leadingIcon = Icons.hotel_outlined;
                      leadingBg = const Color(0xFFF1F5F9);
                      leadingColor = AppColors.muted;
                    }

                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelectRoomPage(hotel: _toUiHotel(hotel)),
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1F3F6)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: leadingBg,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                leadingIcon,
                                color: leadingColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotel.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.text,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    hotel.location,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: AppColors.muted,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'REKOMENDASI EKSKLUSIF',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              
              // Exclusive Recommendations Grid side-by-side
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Tall Card
                  Expanded(
                    child: Container(
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=500&auto=format&fit=crop'
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.65),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'STAYCATION',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white.withValues(alpha: 0.85),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Resor Puncak',
                                  style: TextStyle(
                                    fontSize: 15,
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
                  ),
                  const SizedBox(width: 12),
                  // Right Two Cards Stacked
                  Expanded(
                    child: SizedBox(
                      height: 230,
                      child: Column(
                        children: [
                          // Top Image Card
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                image: const DecorationImage(
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=500&auto=format&fit=crop'
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Bottom Blue Promo Card
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Promo Hari Ini',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white.withValues(alpha: 0.95),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Rekomendasi Untuk Anda',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: AppColors.text,
                ),
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

  String _formatPrice(int price) {
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return 'Rp${price.toString().replaceAllMapped(reg, (Match m) => '${m[1]}.')}';
  }

  UiHotel _toUiHotel(api.Hotel hotel) {
    return UiHotel(
      name: hotel.name,
      location: hotel.location,
      price: _formatPrice(hotel.pricePerNight),
      rating: hotel.rating,
      image: hotel.image,
      distance: hotel.distance,
    );
  }
}


