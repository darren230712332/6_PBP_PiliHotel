import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/widgets/hotel_card.dart';
import '../core/models/room.dart' as api;
import '../core/services/hotel_service.dart';
import '../core/widgets/custom_appbar.dart';
// Removed duplicate import
import '../core/widgets/primary_button.dart';
import '../core/widgets/rating_widget.dart';
// booking_page import not needed here
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
      appBar: CustomAppBar(title: widget.hotel.name),
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
              const Text(
                'DAFTAR KAMAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 12),
              for (int i = 0; i < rooms.length; i++) ...[
                _RoomCard(
                  name: rooms[i].name,
                  rating: rooms[i].rating,
                  price: 'Rp${rooms[i].pricePerNight}',
                  capacity: '${rooms[i].capacity} Tamu',
                  bed: '${rooms[i].bedCount ?? 1} Bed',
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
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({
    required this.name,
    required this.rating,
    required this.price,
    required this.capacity,
    required this.bed,
    required this.onTap,
  });

  final String name;
  final double rating;
  final String price;
  final String capacity;
  final String bed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          Stack(
            children: [
              HotelImage(
                kind: 'modern',
                height: 160,
                width: double.infinity,
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: RatingWidget(rating: rating),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      capacity,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      bed,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        price,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: PrimaryButton(
                        text: 'Pilih Kamar',
                        onPressed: onTap,
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
