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

class Room {
  final int id;
  final int hotelId;
  final String name;
  final String? description;
  final int pricePerNight;
  final int capacity;
  final int? bedCount;
  final List<String>? facilities;
  final List<String> photos;
  final double rating;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.hotelId,
    required this.name,
    this.description,
    required this.pricePerNight,
    required this.capacity,
    this.facilities,
    this.bedCount,
    required this.photos,
    required this.rating,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    List<String> photosList = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        photosList = List<String>.from(json['photos']);
      } else if (json['photos'] is String) {
        photosList = [json['photos']];
      }
    }

    List<String>? facilitiesList;
    if (json['facilities'] != null) {
      if (json['facilities'] is List) {
        facilitiesList = List<String>.from(json['facilities']);
      } else if (json['facilities'] is String) {
        facilitiesList = [json['facilities']];
      }
    }
    return Room(
      id: _asInt(json['id']),
      hotelId: _asInt(json['hotel_id'] ?? json['hotelId']),
      name: json['name'] ?? '',
      description: json['description'],
      pricePerNight: _asInt(json['price_per_night'] ?? json['pricePerNight']),
      capacity: _asInt(json['capacity'], 1),
      bedCount: json['bed_count'] != null || json['bedCount'] != null
          ? _asInt(json['bed_count'] ?? json['bedCount'])
          : null,
      facilities: facilitiesList,
      photos: photosList,
      rating: _asDouble(json['rating']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hotel_id': hotelId,
      'name': name,
      'description': description,
      'price_per_night': pricePerNight,
      'capacity': capacity,
      'bed_count': bedCount,
      'facilities': facilities,
      'photos': photos,
      'rating': rating,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
