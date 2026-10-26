import 'package:dali_alsham/features/places/data/datasources/places_remote_datasource.dart';
import 'package:dali_alsham/features/places/data/models/place_model.dart';
import 'package:dali_alsham/features/places/data/repositories/places_repository_impl.dart';
import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/entities/place_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements PlacesRemoteDataSource {}

void main() {
  late _MockRemote remote;
  late PlacesRepositoryImpl repository;

  final nearby = [
    const PlaceModel(
      id: 'node/1',
      name: 'Far Cafe',
      nameAr: null,
      category: PlaceCategory.cafe,
      latitude: 0.02,
      longitude: 0.0,
    ),
    const PlaceModel(
      id: 'node/2',
      name: 'Near Cafe',
      nameAr: 'مقهى قريب',
      category: PlaceCategory.cafe,
      latitude: 0.001,
      longitude: 0.0,
    ),
  ];

  setUp(() {
    remote = _MockRemote();
    repository = PlacesRepositoryImpl(remote);
    when(
      () => remote.fetchNearbyPlaces(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusMeters: any(named: 'radiusMeters'),
      ),
    ).thenAnswer((_) async => nearby);
  });

  test('sorts places by distance from the user', () async {
    final result = await repository.getNearbyPlaces(latitude: 0, longitude: 0);

    expect(result.isSuccess, isTrue);
    final places = result.getOrElse((_) => []);
    expect(places.first.name, 'Near Cafe');
    expect(places.last.name, 'Far Cafe');
    expect(places.first.distanceMeters, isNotNull);
    expect(places.first.distanceMeters! < places.last.distanceMeters!,
        isTrue);
  });

  test('maps data source exceptions to failures', () async {
    when(
      () => remote.fetchNearbyPlaces(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusMeters: any(named: 'radiusMeters'),
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.getNearbyPlaces(latitude: 0, longitude: 0);

    expect(result, isA<FailureResult<List<Place>>>());
    final failure = switch (result) {
      FailureResult<List<Place>>(:final failure) => failure,
      _ => throw StateError('expected failure'),
    };
    expect(failure, isA<NetworkFailure>());
  });
}
