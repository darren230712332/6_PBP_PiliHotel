import 'package:flutter/material.dart';

import '../core/colors.dart';
import '../core/models/hotel.dart' as api;
import '../core/services/hotel_service.dart';
import '../core/widgets/custom_appbar.dart';
import '../core/widgets/hotel_card.dart';
import '../core/widgets/primary_button.dart';
import '../core/widgets/rating_widget.dart';
import 'select_room_page.dart';

class HotelDetailPage extends StatefulWidget {
  const HotelDetailPage({super.key, required this.hotel});

  final UiHotel hotel;

  @override
  State<HotelDetailPage> createState() => _HotelDetailPageState();
}

class _HotelDetailPageState extends State<HotelDetailPage> {
  final HotelService _hotelService = HotelService();
  late final Future<api.Hotel> _hotelFuture = _resolveHotel();

  Future<api.Hotel> _resolveHotel() async {
    final hotels = await _hotelService.getHotels();
    final matchedHotel = hotels.firstWhere(
      (hotel) => hotel.name.toLowerCase() == widget.hotel.name.toLowerCase(),
      orElse: () => hotels.first,
    );
    return _hotelService.getHotelDetail(matchedHotel.id);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<api.Hotel>(
      future: _hotelFuture,
      builder: (context, snapshot) {
        final fallbackPrice =
                int.tryParse(widget.hotel.price.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;

        final displayHotel = snapshot.data ?? api.Hotel.fromJson({
          'id': 0,
          'name': widget.hotel.name,
          'location': widget.hotel.location,
          'price_per_night': fallbackPrice,
          'rating': widget.hotel.rating,
          'image': widget.hotel.image,
          'distance': widget.hotel.distance,
          'description': 'Hotel modern dengan kamar luas, fasilitas premium, area bersih, dan akses mudah ke pusat kota.',
          'rooms': [],
          'created_at': DateTime.now().toIso8601String(),
        });

        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final facilities = displayHotel.rooms?.isNotEmpty == true
            ? displayHotel.rooms!.first.facilities ?? []
            : ['WiFi', 'Pool', 'Parkir', 'Resto'];

        return Scaffold(
          appBar: CustomAppBar(title: displayHotel.name),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 96),
            children: [
              Stack(
                children: [
                  HotelImage(
                    kind: displayHotel.image,
                    height: 222,
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
                      child: RatingWidget(rating: displayHotel.rating.toDouble()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      displayHotel.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const Icon(Icons.favorite, color: AppColors.danger),
                ],
              ),
              const SizedBox(height: 7),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    displayHotel.location,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text(
                'Deskripsi',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              Text(
                displayHotel.description ??
                    'Hotel modern dengan kamar luas, fasilitas premium, area bersih, dan akses mudah ke pusat kota. Cocok untuk liburan keluarga maupun perjalanan bisnis.',
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.55,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Fasilitas',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 18,
                runSpacing: 12,
                children: [
                  for (final facility in facilities)
                    _Facility(icon: Icons.star, text: facility.toString()),
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
                    '${widget.hotel.price}\n/malam',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PrimaryButton(
                    text: 'Pilih Kamar',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectRoomPage(hotel: widget.hotel),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Facility extends StatelessWidget {
  const _Facility({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      child: Column(
        children: [
          Icon(icon, color: AppColors.primaryBlue, size: 22),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.muted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}