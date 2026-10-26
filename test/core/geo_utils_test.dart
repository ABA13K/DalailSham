import 'package:dali_alsham/core/utils/geo_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GeoUtils.distanceMeters', () {
    test('is ~111.2 km per degree of latitude', () {
      final meters = GeoUtils.distanceMeters(
        fromLat: 0,
        fromLon: 0,
        toLat: 1,
        toLon: 0,
      );
      expect(meters, closeTo(111195, 500));
    });

    test('is zero for identical points', () {
      final meters = GeoUtils.distanceMeters(
        fromLat: 33.5138,
        fromLon: 36.2765,
        toLat: 33.5138,
        toLon: 36.2765,
      );
      expect(meters, 0);
    });

    test('matches known Damascus → Beirut distance (~83 km)', () {
      final meters = GeoUtils.distanceMeters(
        fromLat: 33.5138,
        fromLon: 36.2765,
        toLat: 33.8938,
        toLon: 35.5018,
      );
      expect(meters / 1000, closeTo(83, 5));
    });
  });
}
