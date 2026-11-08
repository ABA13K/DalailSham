import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/presentation/locale_cubit.dart';
import '../core/settings/presentation/theme_cubit.dart';
import '../core/settings/presentation/token_cubit.dart';
import '../core/theme/app_theme.dart';
import '../di/injection.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/banners/domain/usecases/get_banners.dart';
import '../features/banners/presentation/cubit/banners_cubit.dart';
import '../features/categories/domain/usecases/get_random_categories.dart';
import '../features/categories/presentation/cubit/categories_cubit.dart';
import '../features/favorites/domain/repositories/favorites_repository.dart';
import '../features/favorites/presentation/cubit/favorites_cubit.dart';
import '../features/location/domain/usecases/get_current_location.dart';
import '../features/location/domain/usecases/has_location_access.dart';
import '../features/location/presentation/location_cubit.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/places/domain/usecases/get_nearby_places.dart';
import '../features/places/presentation/bloc/places_bloc.dart';
import '../features/places/presentation/cubit/stories_seen_cubit.dart';
import '../features/regions/domain/usecases/get_random_regions.dart';
import '../features/regions/presentation/cubit/regions_cubit.dart';
import '../features/services/domain/usecases/get_service_page.dart';
import '../features/services/presentation/cubit/nearby_cubit.dart';
import '../features/services/presentation/cubit/services_cubit.dart';
import '../features/services/presentation/cubit/top_rated_cubit.dart';
import '../features/stories/domain/usecases/get_story_feed.dart';
import '../features/stories/presentation/cubit/story_feed_cubit.dart';
import '../features/tutorial/presentation/tutorial_cubit.dart';
import '../l10n/generated/app_localizations.dart';
import 'router.dart';

/// Root widget: DI-provided blocs + router + localization.
class DaliAlshamApp extends StatefulWidget {
  const DaliAlshamApp({super.key});

  @override
  State<DaliAlshamApp> createState() => _DaliAlshamAppState();
}

class _DaliAlshamAppState extends State<DaliAlshamApp> {
  late final LocaleCubit _localeCubit = LocaleCubit(getIt())..load();
  late final ThemeCubit _themeCubit = ThemeCubit(getIt())..load();
  late final TokenCubit _tokenCubit = TokenCubit(getIt())..load();
  late final LocationCubit _locationCubit = LocationCubit(
    getIt<GetCurrentLocation>(),
    getIt<HasLocationAccess>(),
  );
  late final StoriesSeenCubit _storiesSeenCubit = StoriesSeenCubit(getIt())
    ..load();
  late final TutorialCubit _tutorialCubit = TutorialCubit(getIt())..load();

  @override
  void dispose() {
    _localeCubit.close();
    _themeCubit.close();
    _tokenCubit.close();
    _locationCubit.close();
    _storiesSeenCubit.close();
    _tutorialCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _localeCubit),
        BlocProvider.value(value: _themeCubit),
        BlocProvider.value(value: _tokenCubit),
        BlocProvider.value(value: _locationCubit),
        BlocProvider.value(value: _storiesSeenCubit),
        BlocProvider.value(value: _tutorialCubit),
        BlocProvider(create: (_) => PlacesBloc(getIt<GetNearbyPlaces>())),
        BlocProvider(
          create: (_) => CategoriesCubit(getIt<GetRandomCategories>()),
        ),
        BlocProvider(create: (_) => RegionsCubit(getIt<GetRandomRegions>())),
        BlocProvider(create: (_) => BannersCubit(getIt<GetBanners>())),
        BlocProvider(create: (_) => TopRatedCubit(getIt<GetServicePage>())),
        BlocProvider(create: (_) => NearbyCubit(getIt<GetServicePage>())),
        // The list under the home search field, read page by page.
        BlocProvider(create: (_) => ServicesCubit(getIt<GetServicePage>())),
        // The stories services posted, shown to everyone on the home strip.
        BlocProvider(create: (_) => StoryFeedCubit(getIt<GetStoryFeed>())),
        BlocProvider(
          create: (_) => FavoritesCubit(getIt<FavoritesRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              AuthCubit(getIt<AuthRepository>(), context.read<TokenCubit>())
                ..load(),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          final router = _router ??= createRouter(
            onboarding: getIt<OnboardingRepository>(),
          );
          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) => MaterialApp.router(
              title: 'Dali Alsham',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeMode,
              locale: locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: router,
            ),
          );
        },
      ),
    );
  }

  GoRouter? _router;
}
