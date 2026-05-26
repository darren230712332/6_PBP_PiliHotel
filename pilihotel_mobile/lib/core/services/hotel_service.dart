import 'dart:convert';

import '../models/hotel.dart';
import 'http_client.dart';

class HotelService {
  HotelService({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<List<Hotel>> getHotels() async {
    final response = await _httpClient.get('/hotels');
    if (response.statusCode != 200) {
      throw Exception('Failed to load hotels');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Hotel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Hotel>> getNearbyHotels() async {
    final response = await _httpClient.get('/hotels/nearby');
    if (response.statusCode != 200) {
      throw Exception('Failed to load nearby hotels');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Hotel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Hotel> getHotelDetail(int hotelId) async {
    final response = await _httpClient.get('/hotels/$hotelId');
    if (response.statusCode != 200) {
      throw Exception('Failed to load hotel detail');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Hotel.fromJson(decoded['data'] as Map<String, dynamic>);
  }
}