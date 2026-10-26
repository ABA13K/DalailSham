import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/settings/data/shared_preferences_locale_repository.dart';
import '../core/settings/domain/locale_repository.dart';
import '../features/location/data/geolocator_location_repository.dart';
import '../features/location/domain/repositories/location_repository.dart';
import '../features/location/domain/usecases/get_current_location.dart';
import '../features/onboarding/data/shared_preferences_onboarding_repository.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/places/data/datasources/places_remote_datasource.dart';
import '../features/places/data/repositories/places_repository_impl.dart';
import '../features/places/domain/repositories/places_repository.dart';
import '../features/places/domain/usecases/get_nearby_places.dart';

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
  getIt.registerLazySingleton<OnboardingRepository>(
    () => SharedPreferencesOnboardingRepository(getIt()),
  );

  // Location feature
  getIt.registerLazySingleton<LocationRepository>(
    () => const GeolocatorLocationRepository(),
  );
  getIt.registerLazySingleton(() => GetCurrentLocation(getIt()));

  // Places feature
  getIt.registerLazySingleton<PlacesRemoteDataSource>(
    () => OverpassPlacesRemoteDataSource(getIt()),
  );
  getIt.registerLazySingleton<PlacesRepository>(
    () => PlacesRepositoryImpl(getIt()),
  );
  getIt.registerLazySingleton(() => GetNearbyPlaces(getIt()));
}

Future<void> resetDependencies() => getIt.reset();
