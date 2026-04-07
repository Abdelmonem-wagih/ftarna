import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Location coordinates
class LocationCoordinates {
  final double latitude;
  final double longitude;

  const LocationCoordinates({
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() => 'LocationCoordinates($latitude, $longitude)';
}

/// Location service for GPS handling
/// Note: This is a simplified implementation. For production,
/// add the geolocator package and implement proper permission handling.
class LocationService {
  LocationCoordinates? _lastKnownLocation;
  final _locationController = StreamController<LocationCoordinates?>.broadcast();

  /// Stream of location updates
  Stream<LocationCoordinates?> get locationStream => _locationController.stream;

  /// Get last known location
  LocationCoordinates? get lastKnownLocation => _lastKnownLocation;

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    // TODO: Implement with geolocator package
    // return await Geolocator.isLocationServiceEnabled();
    return true;
  }

  /// Check and request location permission
  Future<bool> checkAndRequestPermission() async {
    // TODO: Implement with geolocator package
    // LocationPermission permission = await Geolocator.checkPermission();
    // if (permission == LocationPermission.denied) {
    //   permission = await Geolocator.requestPermission();
    // }
    // return permission == LocationPermission.always ||
    //        permission == LocationPermission.whileInUse;
    return true;
  }

  /// Get current location
  Future<LocationCoordinates?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        debugPrint('Location permission denied');
        return null;
      }

      // TODO: Implement with geolocator package
      // final position = await Geolocator.getCurrentPosition(
      //   desiredAccuracy: LocationAccuracy.high,
      // );
      // _lastKnownLocation = LocationCoordinates(
      //   latitude: position.latitude,
      //   longitude: position.longitude,
      // );

      // For now, return a default location (Cairo, Egypt)
      _lastKnownLocation = const LocationCoordinates(
        latitude: 30.0444,
        longitude: 31.2357,
      );

      _locationController.add(_lastKnownLocation);
      return _lastKnownLocation;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Start location updates
  void startLocationUpdates() {
    // TODO: Implement with geolocator package
    // _positionStreamSubscription = Geolocator.getPositionStream(
    //   locationSettings: const LocationSettings(
    //     accuracy: LocationAccuracy.high,
    //     distanceFilter: 100,
    //   ),
    // ).listen((position) {
    //   _lastKnownLocation = LocationCoordinates(
    //     latitude: position.latitude,
    //     longitude: position.longitude,
    //   );
    //   _locationController.add(_lastKnownLocation);
    // });
  }

  /// Stop location updates
  void stopLocationUpdates() {
    // TODO: Cancel stream subscription
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadiusKm = 6371.0;

    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Calculate distance from current location
  double? calculateDistanceFromCurrent(double lat, double lng) {
    if (_lastKnownLocation == null) return null;
    return calculateDistance(
      _lastKnownLocation!.latitude,
      _lastKnownLocation!.longitude,
      lat,
      lng,
    );
  }

  /// Format distance for display
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} m';
    } else {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
  }

  double _toRadians(double degree) => degree * math.pi / 180;

  /// Dispose resources
  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }
}
