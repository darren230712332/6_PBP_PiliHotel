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
    this.borderRadius,
  });

  final String kind;
  final double height;
  final double? width;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isUrl = kind.startsWith('http');
    final String imageUrl = isUrl ? kind : _mapKindToUrl(kind);

    return Container(
      height: height,
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: borderRadius ?? BorderRadius.circular(10),
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.primaryBlue.withOpacity(0.08),
            alignment: Alignment.center,
            child: const Icon(
              Icons.hotel_outlined,
              color: AppColors.muted,
              size: 24,
            ),
          );
        },
      ),
    );
  }

  String _mapKindToUrl(String key) {
    switch (key) {
      case 'pool':
        return 'https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=600&q=80';
      case 'sea':
        return 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?auto=format&fit=crop&w=600&q=80';
      case 'night':
        return 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=600&q=80';
      case 'modern':
        return 'https://images.unsplash.com/photo-1590490360182-c33d57733427?auto=format&fit=crop&w=600&q=80';
      case 'corridor':
        return 'https://images.unsplash.com/photo-1544161515-4ab6ce6db874?auto=format&fit=crop&w=600&q=80';
      case 'bed':
      default:
        return 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=600&q=80';
    }
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
