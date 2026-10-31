import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/places/domain/entities/nearby_places.dart';

abstract interface class PlacesRepository {
  /// Fetches places around [latitude]/[longitude] sorted by distance.
  Future<Result<NearbyPlaces>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters,
  });
}
