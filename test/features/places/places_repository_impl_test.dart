import 'package:dali_alsham/features/places/data/datasources/places_remote_datasource.dart';
import 'package:dali_alsham/features/places/data/models/place_model.dart';
import 'package:dali_alsham/features/places/data/repositories/places_repository_impl.dart';
import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/places/domain/entities/nearby_places.dart';
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

  test('sorts live places by distance from the user', () async {
    final result = await repository.getNearbyPlaces(latitude: 0, longitude: 0);

    expect(result.isSuccess, isTrue);
    final nearby = result.getOrElse((_) => const NearbyPlaces(places: []));
    expect(nearby.places.first.name, 'Near Cafe');
    expect(nearby.places.last.name, 'Far Cafe');
    expect(nearby.places.first.distanceMeters, isNotNull);
    expect(
      nearby.places.first.distanceMeters! < nearby.places.last.distanceMeters!,
      isTrue,
    );
  });

  test('reports the network failure when the API fails', () async {
    when(
      () => remote.fetchNearbyPlaces(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusMeters: any(named: 'radiusMeters'),
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.getNearbyPlaces(
      latitude: 33.51,
      longitude: 36.29,
    );

    expect(result, isA<FailureResult<NearbyPlaces>>());
    final failure = switch (result) {
      FailureResult<NearbyPlaces>(:final failure) => failure,
      _ => throw StateError('expected failure'),
    };
    expect(failure, isA<NetworkFailure>());
  });

  test('surfaces unexpected errors as failures', () async {
    when(
      () => remote.fetchNearbyPlaces(
        latitude: any(named: 'latitude'),
        longitude: any(named: 'longitude'),
        radiusMeters: any(named: 'radiusMeters'),
      ),
    ).thenThrow(StateError('boom'));

    final result = await repository.getNearbyPlaces(latitude: 0, longitude: 0);

    expect(result, isA<FailureResult<NearbyPlaces>>());
    final failure = switch (result) {
      FailureResult<NearbyPlaces>(:final failure) => failure,
      _ => throw StateError('expected failure'),
    };
    expect(failure, isA<UnexpectedFailure>());
  });
}
