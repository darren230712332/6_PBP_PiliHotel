import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<int> _historyIds = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('recent_hotel_ids') ?? [];
    setState(() {
      _historyIds = ids.map((e) => int.tryParse(e)).whereType<int>().toList();
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('recent_hotel_ids', _historyIds.map((e) => e.toString()).toList());
  }

  void _addToHistory(int hotelId) {
    setState(() {
      _historyIds.remove(hotelId);
      _historyIds.insert(0, hotelId);
      if (_historyIds.length > 5) {
        _historyIds = _historyIds.sublist(0, 5);
      }
    });
    _saveHistory();
  }

  void _clearHistory() {
    setState(() {
      _historyIds.clear();
    });
    _saveHistory();
  }

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
              if (query.isEmpty && _historyIds.isNotEmpty) ...[
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
                      onTap: _clearHistory,
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
                for (final historyId in _historyIds.take(3)) ...[
                  Builder(
                    builder: (context) {
                      final hotelIndex = hotels.indexWhere((h) => h.id == historyId);
                      if (hotelIndex == -1) return const SizedBox.shrink();
                      final hotel = hotels[hotelIndex];
                      
                      final idx = _historyIds.indexOf(historyId);
                      late final IconData leadingIcon;
                      late final Color leadingBg;
                      late final Color leadingColor;

                      if (idx == 0) {
                        leadingIcon = Icons.history;
                        leadingBg = const Color(0xFFEAF4FF);
                        leadingColor = AppColors.primaryBlue;
                      } else if (idx == 1) {
                        leadingIcon = Icons.location_on_outlined;
                        leadingBg = const Color(0xFFF1F5F9);
                        leadingColor = AppColors.muted;
                      } else {
                        leadingIcon = Icons.hotel_outlined;
                        leadingBg = const Color(0xFFF1F5F9);
                        leadingColor = AppColors.muted;
                      }

                      return GestureDetector(
                        onTap: () {
                          _addToHistory(hotel.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SelectRoomPage(hotel: _toUiHotel(hotel)),
                            ),
                          ).then((_) {
                            _loadHistory();
                          });
                        },
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
              ],
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
                  onTap: () {
                    _addToHistory(hotel.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectRoomPage(hotel: _toUiHotel(hotel)),
                      ),
                    ).then((_) {
                      _loadHistory();
                    });
                  },
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


