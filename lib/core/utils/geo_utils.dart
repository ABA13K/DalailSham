import 'dart:math' as math;

/// Geographic helpers (pure Dart, easily unit-tested).
class GeoUtils {
  GeoUtils._();

  static const double earthRadiusMeters = 6371000;

  /// Great-circle (haversine) distance between two coordinates, in meters.
  static double distanceMeters({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
  }) {
    final dLat = _toRadians(toLat - fromLat);
    final dLon = _toRadians(toLon - fromLon);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(fromLat)) *
            math.cos(_toRadians(toLat)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
