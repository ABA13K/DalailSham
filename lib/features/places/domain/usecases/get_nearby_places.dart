import 'package:equatable/equatable.dart';

import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/repositories/places_repository.dart';

class NearbyPlacesParams extends Equatable {
  const NearbyPlacesParams({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 2000,
  });

  final double latitude;
  final double longitude;
  final int radiusMeters;

  @override
  List<Object?> get props => [latitude, longitude, radiusMeters];
}

/// Returns places around a point, nearest first.
class GetNearbyPlaces implements UseCase<List<Place>, NearbyPlacesParams> {
  const GetNearbyPlaces(this._repository);

  final PlacesRepository _repository;

  @override
  Future<Result<List<Place>>> call(NearbyPlacesParams params) {
    return _repository.getNearbyPlaces(
      latitude: params.latitude,
      longitude: params.longitude,
      radiusMeters: params.radiusMeters,
    );
  }
}
