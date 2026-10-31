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

Place _place(
  String id,
  String name,
  PlaceCategory category, {
  String? nameAr,
  String? address,
}) => Place(
  id: id,
  name: name,
  nameAr: nameAr,
  category: category,
  latitude: 0,
  longitude: 0,
  address: address,
);

void main() {
  late _MockGetNearbyPlaces usecase;

  setUpAll(() {
    registerFallbackValue(const NearbyPlacesParams(latitude: 0, longitude: 0));
  });

  final places = [
    _place('node/1', 'Olivia Restaurant', PlaceCategory.restaurant),
    _place('node/2', 'كافيه الشام', PlaceCategory.cafe, nameAr: 'كافيه الشام'),
    _place('node/3', 'City Mall', PlaceCategory.shopping),
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
          .having((s) => s.allPlaces, 'allPlaces', places)
          .having((s) => s.visiblePlaces, 'visiblePlaces', places),
    ],
  );

  blocTest<PlacesBloc, PlacesState>(
    'flags the state when the use case falls back to demo data',
    build: () {
      when(() => usecase(any())).thenAnswer(
        (_) async => Success(NearbyPlaces(places: places, isDemo: true)),
      );
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
          .having((s) => s.status, 'status', PlacesStatus.success)
          .having((s) => s.isDemoData, 'isDemoData', isTrue)
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
    'filters by category without refetching',
    build: () => PlacesBloc(usecase),
    seed: () => const PlacesState(
      status: PlacesStatus.success,
      allPlaces: [],
      visiblePlaces: [],
    ),
    act: (bloc) => bloc.add(const PlaceCategoryFiltered(PlaceCategory.cafe)),
    expect: () => [
      isA<PlacesState>()
          .having((s) => s.category, 'category', PlaceCategory.cafe)
          .having((s) => s.visiblePlaces, 'visiblePlaces', []),
    ],
    verify: (_) => verifyNever(() => usecase(any())),
  );

  blocTest<PlacesBloc, PlacesState>(
    'filters by search query (case-insensitive on latin names)',
    build: () => PlacesBloc(usecase),
    seed: () => PlacesState(
      status: PlacesStatus.success,
      allPlaces: places,
      visiblePlaces: places,
    ),
    act: (bloc) => bloc.add(const PlaceSearchQueryChanged('mall')),
    expect: () => [
      isA<PlacesState>().having((s) => s.query, 'query', 'mall').having(
        (s) => s.visiblePlaces.map((p) => p.id).toList(),
        'visible ids',
        ['node/3'],
      ),
    ],
  );

  blocTest<PlacesBloc, PlacesState>(
    'search matches names only, not addresses',
    build: () => PlacesBloc(usecase),
    seed: () {
      final seeded = [
        _place(
          'node/1',
          'Olivia Restaurant',
          PlaceCategory.restaurant,
          address: 'City Mall Street',
        ),
        _place('node/2', 'City Mall', PlaceCategory.shopping),
      ];
      return PlacesState(
        status: PlacesStatus.success,
        allPlaces: seeded,
        visiblePlaces: seeded,
      );
    },
    act: (bloc) => bloc.add(const PlaceSearchQueryChanged('mall')),
    expect: () => [
      isA<PlacesState>().having(
        (s) => s.visiblePlaces.map((p) => p.id).toList(),
        'visible ids',
        ['node/2'],
      ),
    ],
  );

  blocTest<PlacesBloc, PlacesState>(
    'clearing the category shows all places again',
    build: () => PlacesBloc(usecase),
    seed: () => PlacesState(
      status: PlacesStatus.success,
      allPlaces: places,
      visiblePlaces: places
          .where((p) => p.category == PlaceCategory.cafe)
          .toList(),
      category: PlaceCategory.cafe,
    ),
    act: (bloc) => bloc.add(const PlaceCategoryFiltered(null)),
    expect: () => [
      isA<PlacesState>()
          .having((s) => s.category, 'category', isNull)
          .having((s) => s.visiblePlaces, 'visiblePlaces', places),
    ],
  );
}
