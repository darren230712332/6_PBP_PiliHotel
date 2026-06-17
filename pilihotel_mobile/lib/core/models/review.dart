import '../services/http_client.dart';

int _asInt(dynamic value, [int defaultValue = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    return int.tryParse(value) ?? num.tryParse(value)?.toInt() ?? defaultValue;
  }
  return defaultValue;
}

class Review {
  final int id;
  final int bookingId;
  final int userId;
  final int hotelId;
  final int roomId;
  final int rating;
  final String? comment;
  final List<String>? photos;
  final String? userName;
  final String? userPhotoUrl;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.rating,
    this.comment,
    this.photos,
    this.userName,
    this.userPhotoUrl,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    List<String>? photosList;
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        photosList = List<String>.from(json['photos']);
      } else if (json['photos'] is String) {
        photosList = [json['photos']];
      }
    }

    return Review(
      id: _asInt(json['id']),
      bookingId: _asInt(json['booking_id'] ?? json['bookingId']),
      userId: _asInt(json['user_id'] ?? json['userId']),
      hotelId: _asInt(json['hotel_id'] ?? json['hotelId']),
      roomId: _asInt(json['room_id'] ?? json['roomId']),
      rating: _asInt(json['rating']),
      comment: json['comment'],
      photos: photosList,
      userName: json['user']?['name'],
      userPhotoUrl: HttpClient.formatAssetUrl(json['user']?['photo_url']),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'booking_id': bookingId,
      'user_id': userId,
      'hotel_id': hotelId,
      'room_id': roomId,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      if (userName != null || userPhotoUrl != null)
        'user': {
          if (userName != null) 'name': userName,
          if (userPhotoUrl != null) 'photo_url': userPhotoUrl,
        },
      'created_at': createdAt.toIso8601String(),
    };
  }
}
