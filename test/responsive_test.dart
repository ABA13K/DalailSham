import 'package:dali_alsham/app/app.dart';
import 'package:dali_alsham/app/splash_page.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/settings/domain/locale_repository.dart';
import 'package:dali_alsham/core/settings/domain/theme_repository.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/di/injection.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';
import 'package:dali_alsham/features/banners/domain/usecases/get_banners.dart';
import 'package:dali_alsham/features/categories/domain/entities/category_page.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/categories/domain/usecases/get_category_page.dart';
import 'package:dali_alsham/features/categories/domain/usecases/get_random_categories.dart';
import 'package:dali_alsham/features/chat/domain/entities/chat_message.dart';
import 'package:dali_alsham/features/chat/domain/repositories/chat_repository.dart';
import 'package:dali_alsham/features/location/domain/entities/user_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/get_current_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/has_location_access.dart';
import 'package:dali_alsham/features/onboarding/domain/onboarding_repository.dart';
import 'package:dali_alsham/features/places/domain/entities/nearby_places.dart';
import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/entities/place_category.dart';
import 'package:dali_alsham/features/places/domain/repositories/stories_seen_repository.dart';
import 'package:dali_alsham/features/places/domain/usecases/get_nearby_places.dart';
import 'package:dali_alsham/features/places/presentation/pages/place_details_page.dart';
import 'package:dali_alsham/features/places/presentation/pages/stories_page.dart';
import 'package:dali_alsham/features/places/presentation/widgets/place_card.dart';
import 'package:dali_alsham/features/places/presentation/widgets/place_stories_bar.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/regions/domain/entities/region_page.dart';
import 'package:dali_alsham/features/regions/domain/usecases/get_random_regions.dart';
import 'package:dali_alsham/features/regions/domain/usecases/get_region_page.dart';
import 'package:dali_alsham/features/services/domain/entities/category_service_page.dart';
import 'package:dali_alsham/features/services/domain/usecases/get_category_service_page.dart';
import 'package:dali_alsham/features/tutorial/domain/tutorial_repository.dart';
import 'package:dali_alsham/features/tutorial/presentation/feature_tour.dart';
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

class _MockGetCategoryServicePage extends Mock
    implements GetCategoryServicePage {}

class _MockChatRepository extends Mock implements ChatRepository {}

const _places = [
  Place(
    id: 'node/1',
    name: 'Abu Al Nour Restaurant and Cafe - Mazzeh Branch',
    nameAr: 'مطعم وكافيه أبو النور الدمشقي - فرع المزة الغربية',
    category: PlaceCategory.restaurant,
    latitude: 33.511,
    longitude: 36.293,
    distanceMeters: 120,
    address: 'شارع الجلاء، بناء رقم ١٢، الطابق الأرضي، المزة، دمشق، سوريا',
    openingHours: '09:00 - 24:00',
    phone: '+963 11 123 4567',
  ),
  Place(
    id: 'node/2',
    name: 'Nawfara Cafe',
    nameAr: 'مقهى النوفرة',
    category: PlaceCategory.cafe,
    latitude: 33.512,
    longitude: 36.292,
    distanceMeters: 260,
  ),
  Place(
    id: 'node/3',
    name: 'Souq Al Hamidiya',
    nameAr: 'سوق الحميدية',
    category: PlaceCategory.shopping,
    latitude: 33.513,
    longitude: 36.291,
    distanceMeters: 310,
  ),
  Place(
    id: 'node/4',
    name: 'National Museum of Damascus',
    nameAr: 'المتحف الوطني بدمشق',
    category: PlaceCategory.attraction,
    latitude: 33.514,
    longitude: 36.29,
    distanceMeters: 420,
  ),
  Place(
    id: 'node/5',
    name: 'Al Sham Pharmacy',
    nameAr: 'صيدلية الشام',
    category: PlaceCategory.health,
    latitude: 33.515,
    longitude: 36.289,
    distanceMeters: 480,
  ),
  Place(
    id: 'node/6',
    name: 'Tishreen Park',
    nameAr: 'حديقة تشرين',
    category: PlaceCategory.attraction,
    latitude: 33.516,
    longitude: 36.288,
    distanceMeters: 540,
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  Locale locale = const Locale('ar'),
  double textScale = 1.0,
  bool tutorialCompleted = true,
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
  getIt.registerSingleton<GetCategoryServicePage>(
    _MockGetCategoryServicePage(),
  );
  getIt.registerSingleton<ChatRepository>(_MockChatRepository());

  when(
    () => getIt<LocaleRepository>().getLocaleCode(),
  ).thenAnswer((_) async => locale.languageCode);
  when(
    () => getIt<LocaleRepository>().saveLocaleCode(any()),
  ).thenAnswer((_) async {});
  when(
    () => getIt<ThemeRepository>().getThemeMode(),
  ).thenAnswer((_) async => 'light');
  when(
    () => getIt<ThemeRepository>().saveThemeMode(any()),
  ).thenAnswer((_) async {});
  when(() => getIt<GetCurrentLocation>().call(any())).thenAnswer(
    (_) async => const Success(UserLocation(latitude: 33.51, longitude: 36.29)),
  );
  when(() => getIt<HasLocationAccess>()()).thenAnswer((_) async => true);
  when(
    () => getIt<GetNearbyPlaces>().call(any()),
  ).thenAnswer((_) async => const Success(NearbyPlaces(places: _places)));
  when(
    () => getIt<OnboardingRepository>().hasCompleted(),
  ).thenAnswer((_) async => true);
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
  when(() => getIt<GetCategoryServicePage>().call(any())).thenAnswer(
    (_) async =>
        const Success(CategoryServicePage(services: [], hasMore: false)),
  );
  when(
    () => getIt<ChatRepository>().getMessages(
      placeId: any(named: 'placeId'),
      placeName: any(named: 'placeName'),
      locale: any(named: 'locale'),
    ),
  ).thenAnswer((_) async => Success<List<ChatMessage>>([]));

  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await tester.pumpWidget(const DaliAlshamApp());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
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
      const CategoryServicePageParams(categoryId: 1, locale: 'en'),
    );
    registerFallbackValue(<String>{});
  });

  tearDown(() => resetDependencies());

  testWidgets('splash wordmark scales down on a 320 width phone', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(home: SplashPage(onboarding: _MockOnboardingRepository())),
    );
    await tester.pump(const Duration(milliseconds: 600));

    final wordmark = find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == 'assets/images/text.png',
    );
    expect(wordmark, findsOneWidget);
    final rect = tester.getRect(wordmark);
    expect(rect.width, lessThanOrEqualTo(272));
    expect(rect.left, greaterThanOrEqualTo(24));
    expect(tester.takeException(), isNull);
  });

  for (final size in const [Size(320, 568), Size(1024, 768)]) {
    testWidgets('home fits $size with large fonts', (tester) async {
      await _pump(tester, size: size, textScale: 2.0);
      expect(find.byType(PlaceStoriesBar), findsOneWidget);
      expect(find.byType(PlaceCard), findsWidgets);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('the whole feed scrolls as one page', (tester) async {
    // Short enough viewport that the six-place feed overflows it.
    await _pump(tester, size: const Size(400, 700));
    expect(find.byType(RefreshIndicator), findsOneWidget);

    final searchBefore = tester.getTopLeft(find.byType(TextField)).dy;
    final cardBefore = tester.getTopLeft(find.byType(PlaceCard).first).dy;

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -260));
    await tester.pumpAndSettle();

    expect(
      tester.getTopLeft(find.byType(TextField)).dy,
      lessThan(searchBefore),
    );
    expect(
      tester.getTopLeft(find.byType(PlaceCard).first).dy,
      lessThan(cardBefore),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('home content is capped and centered on desktop', (tester) async {
    await _pump(tester, size: const Size(1920, 1080));
    final card = tester.getRect(find.byType(PlaceCard).first);
    expect(card.width, lessThanOrEqualTo(720));
    expect(card.center.dx, closeTo(960, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('details fit a tablet', (tester) async {
    await _pump(tester, size: const Size(1024, 768));
    await tester.tap(find.byType(PlaceCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(PlaceDetailsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('business profile fits a small phone with large text', (
    tester,
  ) async {
    await _pump(tester, size: const Size(320, 640), textScale: 2);
    await tester.tap(find.byType(PlaceCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(PlaceDetailsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('story viewer fits a tablet', (tester) async {
    await _pump(tester, size: const Size(1024, 768));
    await tester.tap(find.byKey(const ValueKey('story-ring-node/1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.byType(StoriesPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tour card fits a desktop monitor', (tester) async {
    await _pump(tester, size: const Size(1920, 1080), tutorialCompleted: false);
    expect(find.byType(FeatureTour), findsOneWidget);
    final card = tester
        .widgetList<Material>(find.byType(Material))
        .firstWhere((material) => material.elevation == 8);
    expect(tester.getSize(find.byWidget(card)).width, lessThanOrEqualTo(460));
    expect(tester.takeException(), isNull);
  });
}
