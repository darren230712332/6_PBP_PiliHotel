import 'package:flutter/material.dart';

import '../colors.dart';
import 'primary_button.dart';
import 'rating_widget.dart';

class UiHotel {
  const UiHotel({
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.image,
    this.distance = '1.2 km',
  });

  final String name;
  final String location;
  final String price;
  final double rating;
  final String image;
  final String distance;
}

const hotels = [
  UiHotel(
    name: 'Grand Palace Hotel',
    location: 'Yogyakarta, Indonesia',
    price: 'Rp1.500.000',
    rating: 4.8,
    image: 'bed',
    distance: '0.8 km',
  ),
  UiHotel(
    name: 'The Palace Boutique',
    location: 'Sleman, Indonesia',
    price: 'Rp720.000',
    rating: 4.6,
    image: 'pool',
    distance: '1.5 km',
  ),
  UiHotel(
    name: 'Sea Breeze Resort',
    location: 'Gunung Kidul',
    price: 'Rp850.000',
    rating: 4.7,
    image: 'sea',
    distance: '2.1 km',
  ),
  UiHotel(
    name: 'Urban Stay Suites',
    location: 'Malioboro',
    price: 'Rp500.000',
    rating: 4.5,
    image: 'night',
    distance: '3.4 km',
  ),
];

class HotelImage extends StatelessWidget {
  const HotelImage({
    super.key,
    required this.kind,
    this.height = 126,
    this.width,
  });

  final String kind;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final palettes = switch (kind) {
      'pool' => [
        const Color(0xFFE9B777),
        const Color(0xFF7CD6FF),
        const Color(0xFF164E84),
      ],
      'sea' => [
        const Color(0xFFFFC773),
        const Color(0xFF42C6FF),
        const Color(0xFF0C3567),
      ],
      'night' => [
        const Color(0xFF191D29),
        const Color(0xFFB7834F),
        const Color(0xFF0D1526),
      ],
      _ => [
        const Color(0xFF76553B),
        const Color(0xFFF6E7CF),
        const Color(0xFF2A2F38),
      ],
    };
    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palettes,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: height * .32,
              color: Colors.black.withValues(alpha: .22),
            ),
          ),
          Center(
            child: Container(
              width: (width ?? 190) * .58,
              height: height * .33,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .84),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(50),
                  bottom: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .18),
                    blurRadius: 20,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HotelCard extends StatelessWidget {
  const HotelCard({
    super.key,
    required this.hotel,
    this.horizontal = false,
    this.onTap,
  });

  final UiHotel hotel;
  final bool horizontal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (horizontal) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 210,
          margin: const EdgeInsets.only(right: 14),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HotelImage(kind: hotel.image, height: 116),
              Padding(
                padding: const EdgeInsets.all(10),
                child: _Info(hotel: hotel),
              ),
            ],
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(8),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            HotelImage(kind: hotel.image, height: 86, width: 98),
            const SizedBox(width: 10),
            Expanded(child: _Info(hotel: hotel, compact: true)),
            SizedBox(
              width: 88,
              child: PrimaryButton(text: 'Pesan', onPressed: onTap),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(10),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: .08),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ],
  );
}

class _Info extends StatelessWidget {
  const _Info({required this.hotel, this.compact = false});

  final UiHotel hotel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                hotel.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 12 : 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            RatingWidget(rating: hotel.rating),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 13,
              color: AppColors.muted,
            ),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                hotel.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: AppColors.muted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          '${hotel.price} /malam',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
