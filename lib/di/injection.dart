import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/settings/data/shared_preferences_locale_repository.dart';
import '../core/settings/data/shared_preferences_theme_repository.dart';
import '../core/settings/domain/locale_repository.dart';
import '../core/settings/domain/theme_repository.dart';
import '../features/banners/data/datasources/banner_remote_datasource.dart';
import '../features/banners/data/repositories/banner_repository_impl.dart';
import '../features/banners/domain/repositories/banner_repository.dart';
import '../features/banners/domain/usecases/get_banners.dart';
import '../features/chat/data/local_chat_repository.dart';
import '../features/chat/domain/repositories/chat_repository.dart';
import '../features/categories/data/datasources/category_remote_datasource.dart';
import '../features/categories/data/repositories/category_repository_impl.dart';
import '../features/categories/domain/repositories/category_repository.dart';
import '../features/categories/domain/usecases/get_category_page.dart';
import '../features/categories/domain/usecases/get_random_categories.dart';
import '../features/location/data/geolocator_location_repository.dart';
import '../features/location/domain/repositories/location_repository.dart';
import '../features/location/domain/usecases/get_current_location.dart';
import '../features/location/domain/usecases/has_location_access.dart';
import '../features/onboarding/data/shared_preferences_onboarding_repository.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/places/data/datasources/places_remote_datasource.dart';
import '../features/places/data/repositories/places_repository_impl.dart';
import '../features/places/data/shared_preferences_stories_seen_repository.dart';
import '../features/places/domain/repositories/places_repository.dart';
import '../features/places/domain/repositories/stories_seen_repository.dart';
import '../features/places/domain/usecases/get_nearby_places.dart';
import '../features/regions/data/datasources/region_remote_datasource.dart';
import '../features/regions/data/repositories/region_repository_impl.dart';
import '../features/regions/domain/repositories/region_repository.dart';
import '../features/regions/domain/usecases/get_random_regions.dart';
import '../features/regions/domain/usecases/get_region_page.dart';
import '../features/services/data/datasources/category_service_remote_datasource.dart';
import '../features/services/data/repositories/category_service_repository_impl.dart';
import '../features/services/domain/repositories/category_service_repository.dart';
import '../features/services/domain/usecases/get_category_service_page.dart';
import '../features/tutorial/data/shared_preferences_tutorial_repository.dart';
import '../features/tutorial/domain/tutorial_repository.dart';

final getIt = GetIt.instance;

/// Registers all dependencies. Must run before `runApp`.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // Core
  getIt.registerLazySingleton<Dio>(createDio);
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  getIt.registerLazySingleton<LocaleRepository>(
    () => SharedPreferencesLocaleRepository(getIt()),
  );
  getIt.registerLazySingleton<ThemeRepository>(
    () => SharedPreferencesThemeRepository(getIt()),
  );
  getIt.registerLazySingleton<OnboardingRepository>(
    () => SharedPreferencesOnboardingRepository(getIt()),
  );
  getIt.registerLazySingleton<TutorialRepository>(
    () => SharedPreferencesTutorialRepository(getIt()),
  );

  // Location feature
  getIt.registerLazySingleton<LocationRepository>(
    () => const GeolocatorLocationRepository(),
  );
  getIt.registerLazySingleton(() => GetCurrentLocation(getIt()));
  getIt.registerLazySingleton(() => HasLocationAccess(getIt()));

  // Categories feature
  getIt.registerLazySingleton<CategoryRemoteDataSource>(
    () => DalilCategoryRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetRandomCategories(getIt()));
  getIt.registerLazySingleton(() => GetCategoryPage(getIt()));

  // Regions feature
  getIt.registerLazySingleton<RegionRemoteDataSource>(
    () => DalilRegionRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<RegionRepository>(
    () => RegionRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetRandomRegions(getIt()));
  getIt.registerLazySingleton(() => GetRegionPage(getIt()));

  // Category services feature
  getIt.registerLazySingleton<CategoryServiceRemoteDataSource>(
    () => DalilCategoryServiceRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<CategoryServiceRepository>(
    () => CategoryServiceRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetCategoryServicePage(getIt()));

  // Chat feature (local demo rooms until the backend ships chat endpoints)
  getIt.registerLazySingleton<ChatRepository>(() => LocalChatRepository());

  // Banners feature
  getIt.registerLazySingleton<BannerRemoteDataSource>(
    () => DalilBannerRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<BannerRepository>(
    () => BannerRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetBanners(getIt()));

  // Places feature
  getIt.registerLazySingleton<PlacesRemoteDataSource>(
    () => OverpassPlacesRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<StoriesSeenRepository>(
    () => SharedPreferencesStoriesSeenRepository(getIt()),
  );
  getIt.registerLazySingleton(() => GetNearbyPlaces(getIt()));
}

Future<void> resetDependencies() => getIt.reset();
