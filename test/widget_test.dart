import 'dart:async';

import 'package:dali_alsham/app/app.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/settings/domain/locale_repository.dart';
import 'package:dali_alsham/core/settings/domain/theme_repository.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/core/widgets/shimmer.dart';
import 'package:dali_alsham/di/injection.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';
import 'package:dali_alsham/features/banners/domain/usecases/get_banners.dart';
import 'package:dali_alsham/features/categories/domain/entities/category_page.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/categories/domain/usecases/get_category_page.dart';
import 'package:dali_alsham/features/categories/domain/usecases/get_random_categories.dart';
import 'package:dali_alsham/features/categories/presentation/pages/categories_page.dart';
import 'package:dali_alsham/features/chat/domain/entities/chat_message.dart';
import 'package:dali_alsham/features/chat/domain/repositories/chat_repository.dart';
import 'package:dali_alsham/features/chat/presentation/pages/chat_page.dart';
import 'package:dali_alsham/features/location/domain/entities/user_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/get_current_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/has_location_access.dart';
import 'package:dali_alsham/features/onboarding/domain/onboarding_repository.dart';
import 'package:dali_alsham/features/places/domain/entities/nearby_places.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/entities/place_category.dart';
import 'package:dali_alsham/features/places/domain/repositories/stories_seen_repository.dart';
import 'package:dali_alsham/features/places/domain/usecases/get_nearby_places.dart';
import 'package:dali_alsham/features/places/presentation/pages/stories_page.dart';
import 'package:dali_alsham/features/places/presentation/widgets/advertise_bar.dart';
import 'package:dali_alsham/features/places/presentation/widgets/place_card.dart';
import 'package:dali_alsham/features/places/presentation/widgets/place_menu.dart';
import 'package:dali_alsham/features/places/presentation/widgets/place_stories_bar.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/regions/domain/entities/region_page.dart';
import 'package:dali_alsham/features/regions/domain/usecases/get_random_regions.dart';
import 'package:dali_alsham/features/regions/domain/usecases/get_region_page.dart';
import 'package:dali_alsham/features/regions/presentation/pages/regions_page.dart';
import 'package:dali_alsham/features/regions/presentation/widgets/region_rail.dart';
import 'package:dali_alsham/features/services/domain/entities/service_summary.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/usecases/get_service_page.dart';
import 'package:dali_alsham/features/services/presentation/pages/services_page.dart';
import 'package:dali_alsham/features/tutorial/domain/tutorial_repository.dart';
import 'package:dali_alsham/features/tutorial/presentation/feature_tour.dart';
import 'package:dali_alsham/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockLocaleRepository extends Mock implements LocaleRepository {}

class _MockThemeRepository extends Mock implements ThemeRepository {}

class _MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class _MockHasLocationAccess extends Mock implements HasLocationAccess {}

class _MockGetNearbyPlaces extends Mock implements GetNearbyPlaces {}

class _MockOnboardingRepository extends Mock implements OnboardingRepository {}

class _MockStoriesSeenRepository extends Mock
    implements StoriesSeenRepository {}

class _MockTutorialRepository extends Mock implements TutorialRepository {}

class _MockGetRandomCategories extends Mock implements GetRandomCategories {}

class _MockGetCategoryPage extends Mock implements GetCategoryPage {}

class _MockGetBanners extends Mock implements GetBanners {}

class _MockGetRandomRegions extends Mock implements GetRandomRegions {}

class _MockGetRegionPage extends Mock implements GetRegionPage {}

class _MockGetServicePage extends Mock implements GetServicePage {}

class _MockChatRepository extends Mock implements ChatRepository {}

Future<void> _pumpSplash(
  WidgetTester tester, {
  bool onboardingCompleted = true,
  bool tutorialCompleted = true,
  Result<UserLocation>? location,
  Result<NearbyPlaces>? places,
}) async {
  getIt.registerSingleton<LocaleRepository>(_MockLocaleRepository());
  getIt.registerSingleton<ThemeRepository>(_MockThemeRepository());
  getIt.registerSingleton<GetCurrentLocation>(_MockGetCurrentLocation());
  getIt.registerSingleton<HasLocationAccess>(_MockHasLocationAccess());
  getIt.registerSingleton<GetNearbyPlaces>(_MockGetNearbyPlaces());
  getIt.registerSingleton<OnboardingRepository>(_MockOnboardingRepository());
  getIt.registerSingleton<StoriesSeenRepository>(_MockStoriesSeenRepository());
  getIt.registerSingleton<TutorialRepository>(_MockTutorialRepository());
  getIt.registerSingleton<GetRandomCategories>(_MockGetRandomCategories());
  getIt.registerSingleton<GetCategoryPage>(_MockGetCategoryPage());
  getIt.registerSingleton<GetBanners>(_MockGetBanners());
  getIt.registerSingleton<GetRandomRegions>(_MockGetRandomRegions());
  getIt.registerSingleton<GetRegionPage>(_MockGetRegionPage());
  getIt.registerSingleton<GetServicePage>(_MockGetServicePage());
  getIt.registerSingleton<ChatRepository>(_MockChatRepository());

  when(
    () => getIt<LocaleRepository>().getLocaleCode(),
  ).thenAnswer((_) async => 'en');
  when(
    () => getIt<LocaleRepository>().saveLocaleCode(any()),
  ).thenAnswer((_) async {});
  when(
    () => getIt<ThemeRepository>().getThemeMode(),
  ).thenAnswer((_) async => 'system');
  when(
    () => getIt<ThemeRepository>().saveThemeMode(any()),
  ).thenAnswer((_) async {});
  when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
    (_) async => location ?? const FailureResult(LocationPermissionFailure()),
  );
  when(() => getIt<HasLocationAccess>()()).thenAnswer((_) async => false);
  when(
    () => getIt<GetNearbyPlaces>().call(any()),
  ).thenAnswer((_) async => places ?? const Success(NearbyPlaces(places: [])));
  when(
    () => getIt<OnboardingRepository>().hasCompleted(),
  ).thenAnswer((_) async => onboardingCompleted);
  when(
    () => getIt<OnboardingRepository>().markCompleted(),
  ).thenAnswer((_) async {});
  when(
    () => getIt<StoriesSeenRepository>().getViewedIds(),
  ).thenAnswer((_) async => <String>{});
  when(
    () => getIt<StoriesSeenRepository>().saveViewedIds(any()),
  ).thenAnswer((_) async {});
  when(
    () => getIt<TutorialRepository>().hasCompleted(),
  ).thenAnswer((_) async => tutorialCompleted);
  when(
    () => getIt<TutorialRepository>().setCompleted(any()),
  ).thenAnswer((_) async {});
  when(
    () => getIt<GetRandomCategories>().call(any()),
  ).thenAnswer((_) async => const Success<List<ExploreCategory>>([]));
  when(() => getIt<GetCategoryPage>().call(any())).thenAnswer(
    (_) async => const Success(CategoryPage(categories: [], hasMore: false)),
  );
  when(
    () => getIt<GetBanners>().call(any()),
  ).thenAnswer((_) async => const Success<List<BannerAd>>([]));
  when(
    () => getIt<GetRandomRegions>().call(any()),
  ).thenAnswer((_) async => const Success<List<Region>>([]));
  when(() => getIt<GetRegionPage>().call(any())).thenAnswer(
    (_) async => const Success(RegionPage(regions: [], hasMore: false)),
  );
  when(() => getIt<GetServicePage>().call(any())).thenAnswer(
    (_) async => const Success(ServicePage(services: [], hasMore: false)),
  );
  when(
    () => getIt<ChatRepository>().getMessages(
      placeId: any(named: 'placeId'),
      placeName: any(named: 'placeName'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => Success<List<ChatMessage>>([]));
  when(
    () => getIt<ChatRepository>().sendMessage(
      placeId: any(named: 'placeId'),
      text: any(named: 'text'),
    ),
  ).thenAnswer(
    (_) async => Success(
      ChatMessage(
        id: 'local/1',
        author: '',
        text: 'placeholder',
        createdAt: DateTime(2026, 10, 27, 21),
        isMine: true,
      ),
    ),
  );

  tester.view.physicalSize = const Size(400, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const DaliAlshamApp());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _pumpApp(
  WidgetTester tester, {
  bool tutorialCompleted = true,
  Result<UserLocation>? location,
  Result<NearbyPlaces>? places,
}) async {
  await _pumpSplash(
    tester,
    tutorialCompleted: tutorialCompleted,
    location: location,
    places: places,
  );
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(const NearbyPlacesParams(latitude: 0, longitude: 0));
    registerFallbackValue(const RandomCategoriesParams(locale: 'en'));
    registerFallbackValue(const CategoryPageParams(locale: 'en'));
    registerFallbackValue(const RandomRegionsParams(locale: 'en'));
    registerFallbackValue(const RegionPageParams(locale: 'en'));
    registerFallbackValue(
      const ServicePageParams(
        scope: ServiceScope.category,
        scopeId: 1,
        locale: 'en',
      ),
    );
    registerFallbackValue(<String>{});
  });

  tearDown(() => resetDependencies());

  testWidgets('shows the animated logo splash before the feed', (tester) async {
    await _pumpSplash(tester);

    expect(find.byKey(const ValueKey('splash-logo')), findsOneWidget);
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

  testWidgets('drawer holds language and theme controls', (tester) async {
    await _pumpApp(tester);

    expect(find.byIcon(Icons.translate_rounded), findsNothing);

    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('drawer-language')), findsOneWidget);
    expect(find.byKey(const ValueKey('drawer-theme')), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Dark mode'), findsOneWidget);
  });

  testWidgets('drawer toggles dark mode and persists it', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    Brightness brightness() =>
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness;

    expect(brightness(), Brightness.light);

    await tester.tap(find.byKey(const ValueKey('drawer-theme')));
    await tester.pumpAndSettle();

    expect(brightness(), Brightness.dark);
    verify(() => getIt<ThemeRepository>().saveThemeMode('dark')).called(1);
  });

  testWidgets('drawer switches the app language', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('drawer-language')));
    await tester.pumpAndSettle();

    expect(find.text('الأماكن القريبة'), findsOneWidget);
    verify(() => getIt<LocaleRepository>().saveLocaleCode('ar')).called(1);
  });

  testWidgets('shows the guided tour until it is completed', (tester) async {
    await _pumpApp(tester, tutorialCompleted: false);

    expect(find.byType(FeatureTour), findsOneWidget);
    expect(
      find.text(
        'Tap any circle at the top to preview places full-screen. Watched stories turn grey.',
      ),
      findsOneWidget,
    );

    for (var step = 0; step < 3; step++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Got it'), findsOneWidget);

    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    expect(find.byType(FeatureTour), findsNothing);
    verify(() => getIt<TutorialRepository>().setCompleted(true)).called(1);
  });

  testWidgets('replays the tutorial from the drawer', (tester) async {
    await _pumpApp(tester);
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('drawer-tutorial')));
    await tester.pumpAndSettle();

    expect(find.byType(FeatureTour), findsOneWidget);
    verify(() => getIt<TutorialRepository>().setCompleted(false)).called(1);
  });

  testWidgets('shows ratings on place cards and details', (tester) async {
    const place = Place(
      id: 'node/1',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    final rating = place.rating.toStringAsFixed(1);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.text(rating), findsOneWidget);
    expect(find.text('(${place.ratingCount})'), findsOneWidget);

    await tester.tap(find.byType(PlaceCard));
    await tester.pumpAndSettle();

    expect(find.text('Business profile'), findsOneWidget);
    expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    expect(find.text(rating), findsOneWidget);
  });

  testWidgets('shows a full business profile with quick actions', (
    tester,
  ) async {
    const place = Place(
      id: 'node/42',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      address: 'Straight Street',
      phone: '+963 11 000 0001',
      website: 'alkhawali.example',
      openingHours: '12:00–23:30',
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );

    await tester.tap(find.byType(PlaceCard));
    await tester.pumpAndSettle();

    expect(find.text('Business profile'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.text('Contact & location'), findsOneWidget);
    expect(find.text('Services & amenities'), findsOneWidget);
    expect(find.text('Ratings & reviews'), findsOneWidget);
    expect(find.text('Call'), findsOneWidget);
    expect(find.text('Directions'), findsOneWidget);
    expect(find.text('Visit website'), findsOneWidget);
    expect(find.text('Straight Street'), findsOneWidget);
    expect(find.textContaining('out of 5'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
  });

  testWidgets('opens the place chat room and sends a message', (tester) async {
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
      places: const Success(NearbyPlaces(places: [place])),
    );

    when(
      () => getIt<ChatRepository>().getMessages(
        placeId: any(named: 'placeId'),
        placeName: any(named: 'placeName'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer(
      (_) async => Success<List<ChatMessage>>([
        ChatMessage(
          id: 'demo/1',
          author: 'Sara',
          text: 'Is Nawfara Cafe open tonight?',
          createdAt: DateTime(2026, 10, 27, 18),
        ),
      ]),
    );
    when(
      () => getIt<ChatRepository>().sendMessage(
        placeId: any(named: 'placeId'),
        text: any(named: 'text'),
      ),
    ).thenAnswer((invocation) async {
      final text = invocation.namedArguments[#text] as String;
      return Success(
        ChatMessage(
          id: 'local/1',
          author: '',
          text: text,
          createdAt: DateTime(2026, 10, 27, 21),
          isMine: true,
        ),
      );
    });

    await tester.tap(find.byType(PlaceCard));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chat'));
    await tester.pumpAndSettle();

    expect(find.byType(ChatPage), findsOneWidget);
    expect(find.text('Chat room'), findsOneWidget);
    expect(find.text('Sara'), findsOneWidget);
    expect(find.text('Is Nawfara Cafe open tonight?'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('chat-input')),
      'What time do you close?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('chat-send')));
    await tester.pumpAndSettle();

    // The message must leave the composer and appear as a bubble.
    final field = tester.widget<TextField>(
      find.byKey(const ValueKey('chat-input')),
    );
    expect(field.controller!.text, isEmpty);
    expect(find.text('What time do you close?'), findsOneWidget);
  });

  testWidgets('opens the place story from its profile', (tester) async {
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
      places: const Success(NearbyPlaces(places: [place])),
    );

    await tester.tap(find.byType(PlaceCard));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Watch story'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(StoriesPage);
    expect(viewer, findsOneWidget);
    expect(
      find.descendant(of: viewer, matching: find.text('Nawfara Cafe')),
      findsWidgets,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(StoriesPage), findsNothing);
  });

  testWidgets('profile avatar chooses between photo and story', (tester) async {
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
      places: const Success(NearbyPlaces(places: [place])),
    );

    await tester.tap(find.byType(PlaceCard));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('profile-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Show photo'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Watch story'), findsOneWidget);

    await tester.tap(find.text('Show photo'));
    await tester.pumpAndSettle();
    final photo = find.byKey(const ValueKey('profile-photo'));
    expect(photo, findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('profile-photo-close')));
    await tester.pumpAndSettle();
    expect(photo, findsNothing);

    await tester.tap(find.byKey(const ValueKey('profile-avatar')));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Watch story'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(StoriesPage), findsOneWidget);
  });

  testWidgets('cafes and restaurants show a sample menu', (tester) async {
    Future<void> pumpMenu(PlaceCategory category) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: Scaffold(
            body: SingleChildScrollView(child: PlaceMenu(category: category)),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpMenu(PlaceCategory.cafe);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Coffee'), findsOneWidget);
    expect(find.text('Espresso'), findsOneWidget);
    expect(find.text('18,000 SYP'), findsOneWidget);

    await pumpMenu(PlaceCategory.restaurant);
    expect(find.text('Mezze'), findsOneWidget);
    expect(find.text('Mixed grill'), findsOneWidget);
    expect(find.text('95,000 SYP'), findsOneWidget);

    await pumpMenu(PlaceCategory.bank);
    expect(find.text('Menu'), findsNothing);
  });

  testWidgets('shows live banners between the stories and the search', (
    tester,
  ) async {
    const place = Place(
      id: 'node/1',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );
    // Without banners the bar collapses and leaves no trace in the feed.
    expect(find.text('Ad'), findsNothing);

    when(() => getIt<GetBanners>().call(any())).thenAnswer(
      (_) async => const Success<List<BannerAd>>([
        BannerAd(id: 1, text: '20% discount with Banque Saudi Fransi (BSF)'),
        BannerAd(id: 2, text: 'Free delivery across Damascus this week'),
      ]),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    final ads = find.byType(AdvertiseBar);
    expect(ads, findsOneWidget);
    expect(
      find.text('20% discount with Banque Saudi Fransi (BSF)'),
      findsOneWidget,
    );
    expect(find.text('Ad'), findsOneWidget);
    expect(
      tester.getTopLeft(ads).dy,
      greaterThanOrEqualTo(
        tester.getBottomLeft(find.byType(PlaceStoriesBar)).dy,
      ),
    );
    expect(
      tester.getBottomLeft(ads).dy,
      lessThan(tester.getTopLeft(find.byType(TextField)).dy),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('ad-dot-0'))).width,
      greaterThan(tester.getSize(find.byKey(const ValueKey('ad-dot-1'))).width),
    );

    await tester.pump(AdvertiseBar.autoAdvance);
    await tester.pumpAndSettle();

    expect(
      find.text('Free delivery across Damascus this week'),
      findsOneWidget,
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('ad-dot-1'))).width,
      greaterThan(tester.getSize(find.byKey(const ValueKey('ad-dot-0'))).width),
    );
  });

  testWidgets('shows shimmer placeholders while banners reload', (
    tester,
  ) async {
    const place = Place(
      id: 'node/1',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [place])),
    );
    expect(find.byType(ShimmerBox), findsNothing);

    final pending = Completer<Result<List<BannerAd>>>();
    when(
      () => getIt<GetBanners>().call(any()),
    ).thenAnswer((_) => pending.future);

    await tester.tap(find.byTooltip('Retry'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(ShimmerBox), findsWidgets);

    pending.complete(
      const Success<List<BannerAd>>([
        BannerAd(id: 1, text: '20% discount with Banque Saudi Fransi (BSF)'),
      ]),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ShimmerBox), findsNothing);
    expect(
      find.text('20% discount with Banque Saudi Fransi (BSF)'),
      findsOneWidget,
    );
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
      places: const Success(NearbyPlaces(places: [place])),
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

  testWidgets('stories open and auto-advance to the next place', (
    tester,
  ) async {
    const first = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );
    const second = Place(
      id: 'node/2',
      name: 'Al Khawali Restaurant',
      nameAr: 'مطعم الخوالي',
      category: PlaceCategory.restaurant,
      latitude: 33.512,
      longitude: 36.292,
      distanceMeters: 260,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [first, second])),
    );

    await tester.tap(
      find.descendant(
        of: find.byType(PlaceStoriesBar),
        matching: find.text('Nawfara Cafe'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final viewer = find.byType(StoriesPage);
    expect(viewer, findsOneWidget);
    expect(
      find.descendant(of: viewer, matching: find.text('Nawfara Cafe')),
      findsWidgets,
    );

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.descendant(of: viewer, matching: find.text('Al Khawali Restaurant')),
      findsWidgets,
    );

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.byType(StoriesPage), findsNothing);
  });

  testWidgets('watched stories turn their ring grey', (tester) async {
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
      places: const Success(NearbyPlaces(places: [place])),
    );

    final ring = find.byKey(const ValueKey('story-ring-node/1'));
    BoxDecoration ringDecoration() =>
        tester.widget<Container>(ring).decoration! as BoxDecoration;

    expect(ringDecoration().gradient, isA<SweepGradient>());

    await tester.tap(
      find.descendant(
        of: find.byType(PlaceStoriesBar),
        matching: find.text('Nawfara Cafe'),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    final gradient = ringDecoration().gradient! as LinearGradient;
    expect(gradient.colors, [const Color(0xFFBDBDBD), const Color(0xFF8A8A8A)]);
  });

  testWidgets('search waits for a pause in typing before filtering', (
    tester,
  ) async {
    const cafe = Place(
      id: 'node/1',
      name: 'Nawfara Cafe',
      nameAr: 'مقهى النوفرة',
      category: PlaceCategory.cafe,
      latitude: 33.511,
      longitude: 36.293,
      distanceMeters: 120,
    );
    const park = Place(
      id: 'node/2',
      name: 'Tishreen Park',
      nameAr: 'حديقة تشرين',
      category: PlaceCategory.attraction,
      latitude: 33.512,
      longitude: 36.292,
      distanceMeters: 260,
    );

    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
      places: const Success(NearbyPlaces(places: [cafe, park])),
    );
    expect(find.byType(PlaceCard), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), 'Nawfara');
    await tester.pump();
    expect(find.byType(PlaceCard), findsNWidgets(2));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.byType(PlaceCard), findsOneWidget);
  });

  testWidgets('shows random categories and opens the full list', (
    tester,
  ) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomCategories>().call(any())).thenAnswer(
      (_) async => const Success<List<ExploreCategory>>([
        ExploreCategory(
          id: 1,
          name: 'Restaurants',
          tagline: 'Discover the most delicious dishes',
        ),
      ]),
    );
    when(() => getIt<GetCategoryPage>().call(any())).thenAnswer(
      (_) async => const Success(
        CategoryPage(
          categories: [
            ExploreCategory(
              id: 1,
              name: 'Restaurants',
              tagline: 'Discover the most delicious dishes',
            ),
            ExploreCategory(
              id: 2,
              name: 'Cafés',
              tagline: 'Fresh coffee around the corner',
            ),
          ],
          hasMore: true,
          nextPage: 2,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Explore categories'), findsOneWidget);
    expect(find.text('Discover the most delicious dishes'), findsOneWidget);

    await tester.tap(find.text('See all'));
    await tester.pumpAndSettle();

    final page = find.byType(CategoriesPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(
        of: page,
        matching: find.text('Fresh coffee around the corner'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Load more')),
      findsOneWidget,
    );
  });

  testWidgets('shows random regions and opens the full list', (tester) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomRegions>().call(any())).thenAnswer(
      (_) async => const Success<List<Region>>([
        Region(
          id: 1,
          name: 'Mazzeh',
          welcomePhrase: 'Welcome to Mazzeh',
          servicesCount: 4,
        ),
      ]),
    );
    when(() => getIt<GetRegionPage>().call(any())).thenAnswer(
      (_) async => const Success(
        RegionPage(
          regions: [
            Region(
              id: 1,
              name: 'Mazzeh',
              welcomePhrase: 'Welcome to Mazzeh',
              servicesCount: 4,
            ),
            Region(id: 2, name: 'Dummer', welcomePhrase: 'Welcome to Dummer'),
          ],
          hasMore: true,
          nextPage: 2,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Explore regions'), findsOneWidget);
    expect(find.text('Welcome to Mazzeh'), findsOneWidget);
    expect(find.text('4 services'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(RegionRail),
        matching: find.text('See all'),
      ),
    );
    await tester.pumpAndSettle();

    final page = find.byType(RegionsPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.text('Welcome to Dummer')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Load more')),
      findsOneWidget,
    );
  });

  testWidgets('opens the services of a category', (tester) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomCategories>().call(any())).thenAnswer(
      (_) async => const Success<List<ExploreCategory>>([
        ExploreCategory(id: 1, name: 'Shawarma Streets'),
      ]),
    );
    when(() => getIt<GetServicePage>().call(any())).thenAnswer(
      (_) async => const Success(
        ServicePage(
          services: [
            ServiceSummary(
              id: 2,
              name: 'Imran',
              regionName: 'Mazzeh',
              address: 'Damascus',
              rating: 4.5,
              reviewsCount: 7,
              distanceText: '400 m',
            ),
          ],
          hasMore: false,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Shawarma Streets'));
    await tester.pumpAndSettle();

    final page = find.byType(ServicesPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.text('Imran')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Mazzeh')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('400 m')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('(7)')),
      findsOneWidget,
    );

    final params =
        verify(() => getIt<GetServicePage>().call(captureAny())).captured.single
            as ServicePageParams;
    expect(params.scope, ServiceScope.category);
    expect(params.scopeId, 1);
    expect(params.userLat, 33.51);
    expect(params.userLng, 36.29);
  });

  testWidgets('opens the services of a region', (tester) async {
    await _pumpApp(
      tester,
      location: const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    when(() => getIt<GetRandomRegions>().call(any())).thenAnswer(
      (_) async =>
          const Success<List<Region>>([Region(id: 4, name: 'Barzeh Hills')]),
    );
    when(() => getIt<GetServicePage>().call(any())).thenAnswer(
      (_) async => const Success(
        ServicePage(
          services: [
            ServiceSummary(
              id: 1,
              name: 'Al Asad',
              categoryName: 'Restaurants',
              address: 'Damascus',
              rating: 0,
              reviewsCount: 0,
            ),
          ],
          hasMore: false,
        ),
      ),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Barzeh Hills'));
    await tester.pumpAndSettle();

    final page = find.byType(ServicesPage);
    expect(page, findsOneWidget);
    expect(
      find.descendant(of: page, matching: find.text('Al Asad')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: page, matching: find.text('Restaurants')),
      findsOneWidget,
    );

    final params =
        verify(() => getIt<GetServicePage>().call(captureAny())).captured.single
            as ServicePageParams;
    expect(params.scope, ServiceScope.region);
    expect(params.scopeId, 4);
  });

  testWidgets('shows a demo-data notice when live places are unavailable', (
    tester,
  ) async {
    const place = Place(
      id: 'demo/1',
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
      places: const Success(NearbyPlaces(places: [place], isDemo: true)),
    );

    expect(
      find.text('Demo data — live places are unavailable.'),
      findsOneWidget,
    );
    expect(find.byType(PlaceStoriesBar), findsOneWidget);
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

  testWidgets('picks up location access granted while the app was away', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('Open settings'), findsOneWidget);

    when(() => getIt<HasLocationAccess>()()).thenAnswer((_) async => true);
    when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
      (_) async =>
          const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsNothing);
    expect(find.text('No places found nearby'), findsOneWidget);
  });

  testWidgets('refresh retries location while access is blocked', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(find.text('Open settings'), findsOneWidget);

    when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
      (_) async =>
          const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
    );

    await tester.tap(find.byTooltip('Retry'));
    await tester.pumpAndSettle();

    expect(find.text('Open settings'), findsNothing);
    expect(find.text('No places found nearby'), findsOneWidget);
  });
}
