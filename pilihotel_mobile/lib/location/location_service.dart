import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<String> requestPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      return 'location_disabled';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return 'denied';
    }

    if (permission == LocationPermission.deniedForever) {
      return 'denied_forever';
    }

    return 'granted';
  }

  Future<UserLocation> currentLocation() async {
    try {
      final permissionStatus = await requestPermission();
      if (permissionStatus != 'granted') {
        return const UserLocation(
          latitude: -7.7956,
          longitude: 110.3695,
          label: 'Yogyakarta, Indonesia',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        label: '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}',
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
