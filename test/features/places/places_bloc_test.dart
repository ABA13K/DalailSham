import 'package:bloc_test/bloc_test.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/places/domain/entities/nearby_places.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/entities/place_category.dart';
import 'package:dali_alsham/features/places/domain/usecases/get_nearby_places.dart';
import 'package:dali_alsham/features/places/presentation/bloc/places_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetNearbyPlaces extends Mock implements GetNearbyPlaces {}

Place _place(String id, String name, {String? nameAr}) => Place(
  id: id,
  name: name,
  nameAr: nameAr,
  category: PlaceCategory.restaurant,
  latitude: 0,
  longitude: 0,
);

void main() {
  late _MockGetNearbyPlaces usecase;

  setUpAll(() {
    registerFallbackValue(const NearbyPlacesParams(latitude: 0, longitude: 0));
  });

  final places = [
    _place('node/1', 'Olivia Restaurant'),
    _place('node/2', 'كافيه الشام', nameAr: 'كافيه الشام'),
    _place('node/3', 'City Mall'),
  ];

  const params = NearbyPlacesParams(latitude: 10, longitude: 20);

  setUp(() {
    usecase = _MockGetNearbyPlaces();
    when(
      () => usecase(any()),
    ).thenAnswer((_) async => Success(NearbyPlaces(places: places)));
  });

  blocTest<PlacesBloc, PlacesState>(
    'emits [loading, success] when the use case succeeds',
    build: () => PlacesBloc(usecase),
    act: (bloc) => bloc.add(const PlacesRequested(latitude: 10, longitude: 20)),
    expect: () => [
      isA<PlacesState>()
          .having((s) => s.status, 'status', PlacesStatus.loading)
          .having((s) => s.lastRequest, 'lastRequest', params),
      isA<PlacesState>()
          .having((s) => s.status, 'status', PlacesStatus.success)
          .having((s) => s.allPlaces, 'allPlaces', places),
    ],
  );

  blocTest<PlacesBloc, PlacesState>(
    'emits [loading, failure] when the use case fails',
    build: () {
      when(
        () => usecase(any()),
      ).thenAnswer((_) async => const FailureResult(NetworkFailure()));
      return PlacesBloc(usecase);
    },
    act: (bloc) => bloc.add(const PlacesRequested(latitude: 10, longitude: 20)),
    expect: () => [
      isA<PlacesState>().having(
        (s) => s.status,
        'status',
        PlacesStatus.loading,
      ),
      isA<PlacesState>()
          .having((s) => s.status, 'status', PlacesStatus.failure)
          .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
    ],
  );

  blocTest<PlacesBloc, PlacesState>(
    'a refresh reads the coordinates of the last request',
    build: () => PlacesBloc(usecase),
    seed: () =>
        const PlacesState(status: PlacesStatus.success, lastRequest: params),
    act: (bloc) => bloc.add(const PlacesRefreshed()),
    expect: () => [
      isA<PlacesState>().having(
        (s) => s.status,
        'status',
        PlacesStatus.loading,
      ),
      isA<PlacesState>()
          .having((s) => s.status, 'status', PlacesStatus.success)
          .having((s) => s.allPlaces, 'allPlaces', places),
    ],
    verify: (_) => verify(
      () => usecase(const NearbyPlacesParams(latitude: 10, longitude: 20)),
    ).called(1),
  );

  blocTest<PlacesBloc, PlacesState>(
    'a refresh with nothing asked before reads nothing',
    build: () => PlacesBloc(usecase),
    act: (bloc) => bloc.add(const PlacesRefreshed()),
    expect: () => <PlacesState>[],
    verify: (_) => verifyNever(() => usecase(any())),
  );
}
