import 'dart:convert';
import 'dart:io';

import '../models/review.dart';
import 'http_client.dart';

class ReviewService {
  ReviewService({HttpClient? httpClient}) : _httpClient = httpClient ?? HttpClient();

  final HttpClient _httpClient;

  Future<List<Review>> getReviews() async {
    final response = await _httpClient.get('/reviews');
    if (response.statusCode != 200) {
      throw Exception('Failed to load reviews');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final items = decoded['data'] as List<dynamic>? ?? [];
    return items
        .map((item) => Review.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Review> createReview(
    Map<String, dynamic> payload, {
    List<File> photos = const [],
  }) async {
    if (photos.isEmpty) {
      final response = await _httpClient.post('/reviews', body: payload);
      if (response.statusCode != 201) {
        throw Exception('Failed to create review');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return Review.fromJson(decoded['data'] as Map<String, dynamic>);
    }

    final fields = <String, String>{
      'booking_id': payload['booking_id'].toString(),
      'rating': payload['rating'].toString(),
      if (payload['comment'] != null && payload['comment'].toString().trim().isNotEmpty)
        'comment': payload['comment'].toString(),
      if (payload['simulate'] != null)
        'simulate': payload['simulate'].toString(),
    };

    final response = await _httpClient.uploadMultipart(
      '/reviews',
      fields: fields,
      files: {'photos[]': photos},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create review');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Review.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<Review> updateReview(
    int reviewId,
    Map<String, dynamic> payload, {
    List<File> newPhotos = const [],
  }) async {
    if (newPhotos.isEmpty) {
      final response = await _httpClient.put('/reviews/$reviewId', body: payload);
      if (response.statusCode != 200) {
        throw Exception('Failed to update review');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      return Review.fromJson(decoded['data'] as Map<String, dynamic>);
    }

    // If there are new photos, we must use Multipart upload with Laravel's PUT method spoofing
    final fields = <String, String>{
      '_method': 'PUT',
      'rating': payload['rating'].toString(),
      if (payload['comment'] != null && payload['comment'].toString().trim().isNotEmpty)
        'comment': payload['comment'].toString(),
    };

    // Add existing photos to the fields (so Laravel knows which old photos to keep)
    final List<dynamic> oldPhotos = payload['photos'] ?? [];
    for (int i = 0; i < oldPhotos.length; i++) {
      fields['existing_photos[$i]'] = oldPhotos[i].toString();
    }

    final response = await _httpClient.uploadMultipart(
      '/reviews/$reviewId',
      fields: fields,
      files: {'photos[]': newPhotos},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update review');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return Review.fromJson(decoded['data'] as Map<String, dynamic>);
  }

  Future<void> deleteReview(int reviewId) async {
    final response = await _httpClient.delete('/reviews/$reviewId');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete review');
    }
  }
}
