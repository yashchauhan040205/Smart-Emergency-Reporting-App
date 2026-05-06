import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns a human-readable location string using real GPS.
  /// Falls back to a descriptive message if permission denied.
  static Future<String> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return 'Location services disabled';
      }

      // Check & request permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return 'Location permission denied';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return 'Location permission permanently denied';
      }

      // Get current position
      final Position pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 8),
        ),
      );

      // Format: Lat, Lng (rounded to 5 decimal places)
      final lat = pos.latitude.toStringAsFixed(5);
      final lng = pos.longitude.toStringAsFixed(5);
      return 'GPS: $lat, $lng';
    } catch (e) {
      // On web, if geolocation unavailable or timed out
      return 'Unable to get location (${e.runtimeType})';
    }
  }

  /// Returns live position stream for tracking
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        distanceFilter: 10,
      ),
    );
  }
}
