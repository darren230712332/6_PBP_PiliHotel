import 'room.dart';

num _asNum(dynamic value, [num defaultValue = 0]) {
  if (value is num) return value;
  if (value is String) {
    return num.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

int _asInt(dynamic value, [int defaultValue = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? num.tryParse(value)?.toInt() ?? defaultValue;
  }
  return defaultValue;
}

double _asDouble(dynamic value, [double defaultValue = 0.0]) {
  return _asNum(value, defaultValue).toDouble();
}

class Hotel {
  final int id;
  final String name;
  final String location;
  final String? description;
  final int pricePerNight;
  final double rating;
  final String image;
  final String distance;
  final double? latitude;
  final double? longitude;
  final List<Room>? rooms;
  final DateTime createdAt;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    this.description,
    required this.pricePerNight,
    required this.rating,
    required this.image,
    required this.distance,
    this.latitude,
    this.longitude,
    this.rooms,
    required this.createdAt,
  });

  factory Hotel.fromJson(Map<String, dynamic> json) {
    final pricePerNight = _asInt(json['price_per_night'] ?? json['pricePerNight']);

    List<Room>? rooms;
    if (json['rooms'] is List) {
      rooms = List<Room>.from(
        (json['rooms'] as List<dynamic>).map(
          (room) => Room.fromJson(room as Map<String, dynamic>),
        ),
      );
    }

    return Hotel(
      id: _asInt(json['id']),
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      description: json['description'],
      rating: _asDouble(json['rating']),
      image: json['image'] ?? 'bed',
      distance: json['distance'] ?? '0 km',
      pricePerNight: pricePerNight,
      latitude: json['latitude'] != null ? _asDouble(json['latitude']) : null,
      longitude: json['longitude'] != null ? _asDouble(json['longitude']) : null,
      rooms: rooms,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'price_per_night': pricePerNight,
      'rating': rating,
      'image': image,
      'distance': distance,
      'latitude': latitude,
      'longitude': longitude,
      'rooms': rooms?.map((room) => room.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
