import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';

abstract interface class PlacesRepository {
  /// Fetches places around [latitude]/[longitude] sorted by distance.
  Future<Result<List<Place>>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters,
  });
}
