import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/settings/data/shared_preferences_locale_repository.dart';
import '../core/settings/data/shared_preferences_theme_repository.dart';
import '../core/settings/data/shared_preferences_token_repository.dart';
import '../core/settings/domain/locale_repository.dart';
import '../core/settings/domain/theme_repository.dart';
import '../core/settings/domain/token_repository.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/data/shared_preferences_account_repository.dart';
import '../features/auth/domain/repositories/account_repository.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
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
import '../features/favorites/data/datasources/favorites_remote_datasource.dart';
import '../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
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
import '../features/profile/data/datasources/profile_remote_datasource.dart';
import '../features/profile/data/gallery_avatar_picker.dart';
import '../features/profile/data/repositories/profile_repository_impl.dart';
import '../features/profile/domain/repositories/avatar_picker.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/regions/data/datasources/region_remote_datasource.dart';
import '../features/regions/data/repositories/region_repository_impl.dart';
import '../features/regions/domain/repositories/region_repository.dart';
import '../features/regions/domain/usecases/get_random_regions.dart';
import '../features/regions/domain/usecases/get_region_page.dart';
import '../features/services/data/datasources/service_remote_datasource.dart';
import '../features/services/data/repositories/service_repository_impl.dart';
import '../features/services/domain/repositories/service_repository.dart';
import '../features/services/domain/usecases/get_service_page.dart';
import '../features/services/domain/usecases/search_services.dart';
import '../features/service_profile/data/datasources/service_profile_remote_datasource.dart';
import '../features/service_profile/data/repositories/service_profile_repository_impl.dart';
import '../features/service_profile/domain/repositories/service_profile_repository.dart';
import '../features/service_profile/domain/usecases/get_service_detail.dart';
import '../features/service_profile/domain/usecases/get_service_images.dart';
import '../features/service_profile/domain/usecases/get_service_product_categories.dart';
import '../features/service_profile/domain/usecases/get_service_products.dart';
import '../features/service_profile/domain/usecases/get_service_reviews.dart';
import '../features/stories/data/datasources/story_remote_datasource.dart';
import '../features/stories/data/repositories/story_repository_impl.dart';
import '../features/stories/domain/repositories/story_repository.dart';
import '../features/stories/domain/usecases/get_service_story_feed.dart';
import '../features/stories/domain/usecases/get_story_feed.dart';
import '../features/stories/domain/usecases/record_story_view.dart';
import '../features/stories/domain/usecases/vote_story_poll.dart';
import '../features/tutorial/data/shared_preferences_tutorial_repository.dart';
import '../features/tutorial/domain/tutorial_repository.dart';
import '../features/vendor/data/datasources/vendor_amenity_remote_datasource.dart';
import '../features/vendor/data/datasources/vendor_contact_remote_datasource.dart';
import '../features/vendor/data/datasources/vendor_image_remote_datasource.dart';
import '../features/vendor/data/datasources/vendor_picker_remote_datasource.dart';
import '../features/vendor/data/datasources/vendor_product_remote_datasource.dart';
import '../features/vendor/data/datasources/vendor_remote_datasource.dart';
import '../features/vendor/data/datasources/vendor_story_remote_datasource.dart';
import '../features/vendor/data/gallery_story_file_picker.dart';
import '../features/vendor/data/repositories/vendor_amenity_repository_impl.dart';
import '../features/vendor/data/repositories/vendor_contact_repository_impl.dart';
import '../features/vendor/data/repositories/vendor_image_repository_impl.dart';
import '../features/vendor/data/repositories/vendor_picker_repository_impl.dart';
import '../features/vendor/data/repositories/vendor_product_repository_impl.dart';
import '../features/vendor/data/repositories/vendor_repository_impl.dart';
import '../features/vendor/data/repositories/vendor_story_repository_impl.dart';
import '../features/vendor/domain/repositories/vendor_amenity_repository.dart';
import '../features/vendor/domain/repositories/vendor_contact_repository.dart';
import '../features/vendor/domain/repositories/vendor_image_repository.dart';
import '../features/vendor/domain/repositories/vendor_picker_repository.dart';
import '../features/vendor/domain/repositories/vendor_product_repository.dart';
import '../features/vendor/domain/repositories/story_file_picker.dart';
import '../features/vendor/domain/repositories/vendor_repository.dart';
import '../features/vendor/domain/repositories/vendor_story_repository.dart';

final getIt = GetIt.instance;

/// Registers all dependencies. Must run before `runApp`.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // Core
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  getIt.registerLazySingleton<LocaleRepository>(
    () => SharedPreferencesLocaleRepository(getIt()),
  );
  getIt.registerLazySingleton<ThemeRepository>(
    () => SharedPreferencesThemeRepository(getIt()),
  );
  getIt.registerLazySingleton<TokenRepository>(
    () => SharedPreferencesTokenRepository(getIt()),
  );
  getIt.registerLazySingleton<Dio>(
    () => createDio()..interceptors.add(AuthInterceptor(getIt())),
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

  // Services feature (category and region listings)
  getIt.registerLazySingleton<ServiceRemoteDataSource>(
    () => DalilServiceRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetServicePage(getIt()));
  getIt.registerLazySingleton(() => SearchServices(getIt()));

  // Service profile (one service's details, pictures, menu and opinions)
  getIt.registerLazySingleton<ServiceProfileRemoteDataSource>(
    () => DalilServiceProfileRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<ServiceProfileRepository>(
    () => ServiceProfileRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetServiceDetail(getIt()));
  getIt.registerLazySingleton(() => GetServiceImages(getIt()));
  getIt.registerLazySingleton(() => GetServiceProducts(getIt()));
  getIt.registerLazySingleton(() => GetServiceProductCategories(getIt()));
  getIt.registerLazySingleton(() => GetServiceReviews(getIt()));

  // Favorites feature (bearer-token heart toggles)
  getIt.registerLazySingleton<FavoritesRemoteDataSource>(
    () => DalilFavoritesRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(getIt()),
  );

  // Auth feature (login and register, plus the session they store)
  getIt.registerLazySingleton<AccountRepository>(
    () => SharedPreferencesAccountRepository(getIt()),
  );
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => DalilAuthRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt(), getIt()),
  );

  // Profile feature (the signed-in account's own record)
  getIt.registerLazySingleton<ProfileRemoteDataSource>(
    () => DalilProfileRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<AvatarPicker>(() => GalleryAvatarPicker());
  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(getIt(), getIt()),
  );

  // Vendor feature (the signed-in vendor's own service)
  getIt.registerLazySingleton<VendorRemoteDataSource>(
    () => DalilVendorRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<VendorRepository>(
    () => VendorRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<VendorPickerRemoteDataSource>(
    () => DalilVendorPickerRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<VendorPickerRepository>(
    () => VendorPickerRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<VendorContactRemoteDataSource>(
    () => DalilVendorContactRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<VendorContactRepository>(
    () => VendorContactRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<VendorImageRemoteDataSource>(
    () => DalilVendorImageRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<VendorImageRepository>(
    () => VendorImageRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<VendorProductRemoteDataSource>(
    () => DalilVendorProductRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<VendorProductRepository>(
    () => VendorProductRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<VendorAmenityRemoteDataSource>(
    () => DalilVendorAmenityRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<VendorAmenityRepository>(
    () => VendorAmenityRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<VendorStoryRemoteDataSource>(
    () => DalilVendorStoryRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<VendorStoryRepository>(
    () => VendorStoryRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton<StoryFilePicker>(() => GalleryStoryFilePicker());

  // The stories every reader sees, listed to the home feed without a token.
  getIt.registerLazySingleton<StoryRemoteDataSource>(
    () => DalilStoryRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<StoryRepository>(
    () => StoryRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetStoryFeed(getIt()));
  // Everything one service posted, which is the archive behind its story.
  getIt.registerLazySingleton(() => GetServiceStoryFeed(getIt()));
  // What a signed-in reader does with a story: the view it watched and the
  // answer it gave to a poll. Both ride the bearer token.
  getIt.registerLazySingleton(() => RecordStoryView(getIt()));
  getIt.registerLazySingleton(() => VoteStoryPoll(getIt()));

  // Chat feature (empty local rooms until the backend ships chat endpoints)
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
