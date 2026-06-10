import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return 'denied';
    }

    if (permission == LocationPermission.deniedForever) {
      return 'denied_forever';
    }

    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return 'location_disabled';
    }

    return 'granted';
  }

  Future<String> getAddressFromCoords(double latitude, double longitude) async {
    // Local hardcoded cache for Sleman/Yogyakarta mockup coordinates to make them load instantly
    if ((latitude - (-7.7758)).abs() < 0.01 && (longitude - 110.4153).abs() < 0.01) {
      return 'Depok, Sleman';
    }
    if ((latitude - (-7.7956)).abs() < 0.01 && (longitude - 110.3695).abs() < 0.01) {
      return 'Yogyakarta, Indonesia';
    }

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );
      final response = await http.get(
        url,
        headers: {'User-Agent': 'PiliHotelApp/1.0'},
      ).timeout(const Duration(seconds: 3));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['address'];
        if (address != null) {
          final village = address['village'] ?? address['suburb'] ?? address['neighbourhood'] ?? address['quarter'];
          final city = address['city'] ?? address['town'] ?? address['county'] ?? address['city_district'] ?? address['municipality'];
          if (village != null && city != null) {
            return '$village, $city';
          }
          if (city != null) {
            final state = address['state'];
            if (state != null) {
              return '$city, ${state.replaceAll('Daerah Istimewa ', '')}';
            }
            return city;
          }
        }
        return data['display_name']?.split(',').take(2).join(',') ?? 
            '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
      }
    } catch (_) {
      // ignore
    }
    return '${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)}';
  }

  Future<UserLocation> currentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission != LocationPermission.always && permission != LocationPermission.whileInUse) {
        return const UserLocation(
          latitude: -7.7956,
          longitude: 110.3695,
          label: 'Yogyakarta, Indonesia',
        );
      }

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) {
        return const UserLocation(
          latitude: -7.7956,
          longitude: 110.3695,
          label: 'Yogyakarta, Indonesia',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final label = await getAddressFromCoords(position.latitude, position.longitude);

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        label: label,
      );
    } catch (_) {
      return const UserLocation(
        latitude: -7.7956,
        longitude: 110.3695,
        label: 'Yogyakarta, Indonesia',
      );
    }
  }

  double distanceKm({
    required double fromLatitude,
    required double fromLongitude,
    required double toLatitude,
    required double toLongitude,
  }) {
    return Geolocator.distanceBetween(
          fromLatitude,
          fromLongitude,
          toLatitude,
          toLongitude,
        ) /
        1000;
  }
}

class UserLocation {
  const UserLocation({
    required this.latitude,
    required this.longitude,
    required this.label,
  });

  final double latitude;
  final double longitude;
  final String label;
}
