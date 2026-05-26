import 'dart:convert';

import '../models/booking.dart';
import 'http_client.dart';

class BookingService {
  BookingService({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<List<Booking>> getBookings() async {
    final response = await _httpClient.get('/bookings');
    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, 'Failed to load bookings'));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Booking.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> createBooking(Map<String, dynamic> payload) async {
    final response = await _httpClient.post('/bookings', body: payload);
    if (response.statusCode != 201) {
      throw Exception(_extractMessage(response.body, 'Failed to create booking'));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Booking.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<Booking> getBooking(int bookingId) async {
    final response = await _httpClient.get('/bookings/$bookingId');
    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, 'Failed to load booking detail'));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Booking.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<Booking> payBooking(int bookingId, {required String paymentMethod}) async {
    final response = await _httpClient.post(
      '/bookings/$bookingId/pay',
      body: {'payment_method': paymentMethod},
    );

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(response.body, 'Failed to pay booking'));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Booking.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  String _extractMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ?? fallback;
      }
    } catch (_) {
      // Ignore non-JSON error bodies.
    }
    return fallback;
  }
}