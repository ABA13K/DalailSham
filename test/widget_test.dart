import 'package:dali_alsham/app/app.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/settings/domain/locale_repository.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/di/injection.dart';
import 'package:dali_alsham/features/location/domain/entities/user_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/get_current_location.dart';
import 'package:dali_alsham/features/onboarding/domain/onboarding_repository.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/entities/place_category.dart';
import 'package:dali_alsham/features/places/domain/usecases/get_nearby_places.dart';
import 'package:dali_alsham/features/places/presentation/widgets/place_stories_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocaleRepository extends Mock implements LocaleRepository {}

class _MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class _MockGetNearbyPlaces extends Mock implements GetNearbyPlaces {}

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

Future<void> _pumpSplash(
  WidgetTester tester, {
  bool onboardingCompleted = true,
  Result<UserLocation>? location,
  Result<List<Place>>? places,
}) async {
  getIt.registerSingleton<LocaleRepository>(_MockLocaleRepository());
  getIt.registerSingleton<GetCurrentLocation>(_MockGetCurrentLocation());
  getIt.registerSingleton<GetNearbyPlaces>(_MockGetNearbyPlaces());
  getIt.registerSingleton<OnboardingRepository>(_MockOnboardingRepository());

  when(
    () => getIt<LocaleRepository>().getLocaleCode(),
  ).thenAnswer((_) async => 'en');
  when(
    () => getIt<LocaleRepository>().saveLocaleCode(any()),
  ).thenAnswer((_) async {});
  when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
    (_) async => location ?? const FailureResult(LocationPermissionFailure()),
  );
  when(
    () => getIt<GetNearbyPlaces>().call(any()),
  ).thenAnswer((_) async => places ?? const Success([]));
  when(
    () => getIt<OnboardingRepository>().hasCompleted(),
  ).thenAnswer((_) async => onboardingCompleted);
  when(
    () => getIt<OnboardingRepository>().markCompleted(),
  ).thenAnswer((_) async {});

  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const DaliAlshamApp());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _pumpApp(
  WidgetTester tester, {
  Result<UserLocation>? location,
  Result<List<Place>>? places,
}) async {
  await _pumpSplash(tester, location: location, places: places);
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const NearbyPlacesParams(latitude: 0, longitude: 0));
  });

  tearDown(() => resetDependencies());

  testWidgets('shows the branded splash before the feed', (tester) async {
    await _pumpSplash(tester);

    expect(find.text('Dali Alsham'), findsOneWidget);
    expect(find.text('Discover places around you'), findsOneWidget);
    expect(find.text('Nearby places'), findsNothing);
  });

  testWidgets('shows onboarding on first launch', (tester) async {
    await _pumpSplash(tester, onboardingCompleted: false);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Welcome to Dali Alsham'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Nearby places'), findsNothing);
  });

  testWidgets('skipping onboarding opens the feed', (tester) async {
    await _pumpSplash(tester, onboardingCompleted: false);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Nearby places'), findsOneWidget);
    verify(() => getIt<OnboardingRepository>().markCompleted()).called(1);
  });

  testWidgets('shows the nearby-places feed with search and filters', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(find.text('Nearby places'), findsOneWidget);
    expect(find.text('Discover places around you'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });

  testWidgets('shows nearby places as stories above the search field', (
    tester,
  ) async {
    const place = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success([place]),
    );

    final stories = find.byType(PlaceStoriesBar);
    expect(stories, findsOneWidget);
    expect(
      find.descendant(of: stories, matching: find.text('Stories')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: stories, matching: find.text('Nawfara Cafe')),
      findsOneWidget,
    );
    expect(
      tester.getCenter(stories).dy,
      lessThan(tester.getCenter(find.byType(TextField)).dy),
    );
  });

  testWidgets('shows a location permission message when denied', (
    tester,
  ) async {
    await _pumpApp(tester);

    expect(
      find.text(
        'We use your location to find places around you. Please enable it in system settings.',
      ),
      findsOneWidget,
    );
    expect(find.text('Open settings'), findsOneWidget);
  });
}
