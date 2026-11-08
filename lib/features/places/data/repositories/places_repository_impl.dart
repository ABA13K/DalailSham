import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/utils/geo_utils.dart';
import 'package:dali_alsham/features/places/data/datasources/places_remote_datasource.dart';
import 'package:dali_alsham/features/places/data/models/place_model.dart';
import 'package:dali_alsham/features/places/domain/entities/nearby_places.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/repositories/places_repository.dart';

class PlacesRepositoryImpl implements PlacesRepository {
  PlacesRepositoryImpl(this._remoteDataSource);

  final PlacesRemoteDataSource _remoteDataSource;

  @override
  Future<Result<NearbyPlaces>> getNearbyPlaces({
    required double latitude,
    required double longitude,
    int radiusMeters = 2000,
  }) async {
    try {
      final models = await _remoteDataSource.fetchNearbyPlaces(
        latitude: latitude,
        longitude: longitude,
        radiusMeters: radiusMeters,
      );
      return Success(
        NearbyPlaces(
          places: _withDistances(
            models,
            latitude: latitude,
            longitude: longitude,
          ),
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  List<Place> _withDistances(
    Iterable<PlaceModel> models, {
    required double latitude,
    required double longitude,
  }) {
    return models.map((model) {
      final meters = GeoUtils.distanceMeters(
        fromLat: latitude,
        fromLon: longitude,
        toLat: model.latitude,
        toLon: model.longitude,
      );
      return model.copyWithDistance(meters.round());
    }).toList()..sort(
      (a, b) => (a.distanceMeters ?? 0).compareTo(b.distanceMeters ?? 0),
    );
  }
}
