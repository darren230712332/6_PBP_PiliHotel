import 'hotel.dart';
import 'room.dart';
import 'review.dart';
export 'review.dart';

class Booking {
  final int id;
  final int userId;
  final int hotelId;
  final int roomId;
  final String bookingCode;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final List<Map<String, dynamic>>? extras;
  final String? paymentMethod;
  final String paymentStatus;
  final String status;
  final int totalPrice;
  final String? qrCode;
  final Hotel? hotel;
  final Room? room;
  final Review? review;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.hotelId,
    required this.roomId,
    required this.bookingCode,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    this.extras,
    this.paymentMethod,
    required this.paymentStatus,
    required this.status,
    required this.totalPrice,
    this.qrCode,
    this.hotel,
    this.room,
    this.review,
    required this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      hotelId: json['hotel_id'] ?? 0,
      roomId: json['room_id'] ?? 0,
      bookingCode: json['booking_code'] ?? '',
      checkIn: json['check_in'] != null
          ? DateTime.parse(json['check_in'])
          : DateTime.now(),
      checkOut: json['check_out'] != null
          ? DateTime.parse(json['check_out'])
          : DateTime.now(),
      nights: json['nights'] ?? 0,
      extras: json['extras'] != null
          ? List<Map<String, dynamic>>.from(json['extras'])
          : null,
      paymentMethod: json['payment_method'],
      paymentStatus: json['payment_status'] ?? 'pending',
      status: json['status'] ?? 'Menunggu Pembayaran',
      totalPrice: json['total_price'] ?? 0,
      qrCode: json['qr_code'],
      hotel: json['hotel'] != null ? Hotel.fromJson(json['hotel']) : null,
      room: json['room'] != null ? Room.fromJson(json['room']) : null,
      review: json['review'] != null ? Review.fromJson(json['review']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'hotel_id': hotelId,
      'room_id': roomId,
      'booking_code': bookingCode,
      'check_in': checkIn.toIso8601String(),
      'check_out': checkOut.toIso8601String(),
      'nights': nights,
      'extras': extras,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'status': status,
      'total_price': totalPrice,
      'qr_code': qrCode,
      'hotel': hotel?.toJson(),
      'room': room?.toJson(),
      'review': review?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
