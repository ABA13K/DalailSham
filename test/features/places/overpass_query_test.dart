import 'package:dali_alsham/features/places/data/datasources/overpass_query.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('query includes radius, coordinates and a result limit', () {
    final query = buildOverpassQuery(
      latitude: 33.5138,
      longitude: 36.2765,
      radiusMeters: 1500,
      limit: 42,
    );

    expect(query, contains('(around:1500,33.5138,36.2765)'));
    expect(query, contains('out body 42;'));
    expect(query, contains('[out:json]'));
    expect(query, contains('"amenity"'));
    expect(query, contains('"tourism"'));
    expect(query, contains('"shop"'));
  });
}
