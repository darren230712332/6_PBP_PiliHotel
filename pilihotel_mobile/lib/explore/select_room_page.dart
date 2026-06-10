import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/widgets/hotel_card.dart';
import '../core/models/room.dart' as api;
import '../core/services/hotel_service.dart';
import 'room_detail_page.dart';

class SelectRoomPage extends StatefulWidget {
  const SelectRoomPage({super.key, required this.hotel});

  final UiHotel hotel;

  @override
  State<SelectRoomPage> createState() => _SelectRoomPageState();
}

class _SelectRoomPageState extends State<SelectRoomPage> {
  final HotelService _hotelService = HotelService();
  late final Future<List<api.Room>> _roomsFuture = _loadRooms();

  Future<List<api.Room>> _loadRooms() async {
    final hotels = await _hotelService.getHotels();
    final matched = hotels.firstWhere(
      (h) => h.name.toLowerCase() == widget.hotel.name.toLowerCase(),
      orElse: () => hotels.first,
    );
    final detail = await _hotelService.getHotelDetail(matched.id);
    return detail.rooms ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: AppColors.text, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.hotel.name,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'DAFTAR KAMAR',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 0.5,
              ),
            ),
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
      body: FutureBuilder<List<api.Room>>(
        future: _roomsFuture,
        builder: (context, snapshot) {
          final rooms = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting && rooms.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError && rooms.isEmpty) {
            return Center(child: Text('Gagal memuat kamar: ${snapshot.error}'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 96),
            children: [
              for (int i = 0; i < rooms.length; i++) ...[
                _RoomCard(
                  name: rooms[i].name,
                  rating: rooms[i].rating,
                  price: _formatPrice(rooms[i].pricePerNight),
                  capacity: '${rooms[i].capacity} Tamu',
                  size: _getRoomSize(rooms[i].name),
                  image: rooms[i].photos.isNotEmpty ? rooms[i].photos.first : widget.hotel.image,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoomDetailPage(hotel: widget.hotel, room: rooms[i]),
                    ),
                  ),
                ),
                if (i < rooms.length - 1) const SizedBox(height: 14),
              ],
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

  String _getRoomSize(String roomName) {
    final name = roomName.toLowerCase();
    if (name.contains('deluxe')) return '32 m²';
    if (name.contains('executive')) return '45 m²';
    if (name.contains('suite')) return '42 m²';
    if (name.contains('king')) return '36 m²';
    if (name.contains('standard') || name.contains('superior')) return '24 m²';
    return '28 m²';
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.name,
    required this.rating,
    required this.price,
    required this.capacity,
    required this.size,
    required this.image,
    required this.onTap,
  });

  final String name;
  final double rating;
  final String price;
  final String capacity;
  final String size;
  final String image;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7EEF7)),
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
          Stack(
            children: [
              HotelImage(
                kind: image,
                height: 180,
                width: double.infinity,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: AppColors.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      capacity,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      Icons.square_foot,
                      size: 14,
                      color: AppColors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      size,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(
                  color: Color(0xFFF1F3F6),
                  height: 1,
                  thickness: 1,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            price,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            '/malam (Inc. Pajak)',
                            style: TextStyle(
                              fontSize: 9.5,
                              color: AppColors.muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 115,
                      height: 42,
                      child: FilledButton(
                        onPressed: onTap,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Pilih Kamar',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
