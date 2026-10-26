import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import '../core/settings/presentation/locale_cubit.dart';
import '../core/theme/app_theme.dart';
import '../di/injection.dart';
import '../features/location/domain/usecases/get_current_location.dart';
import '../features/location/presentation/location_cubit.dart';
import '../features/onboarding/domain/onboarding_repository.dart';
import '../features/places/domain/usecases/get_nearby_places.dart';
import '../features/places/presentation/bloc/places_bloc.dart';
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
  late final LocationCubit _locationCubit =
      LocationCubit(getIt<GetCurrentLocation>());

  @override
  void dispose() {
    _localeCubit.close();
    _locationCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _localeCubit),
        BlocProvider.value(value: _locationCubit),
        BlocProvider(
          create: (_) => PlacesBloc(getIt<GetNearbyPlaces>()),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          final router = _router ??=
              createRouter(onboarding: getIt<OnboardingRepository>());
          return MaterialApp.router(
            title: 'Dali Alsham',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: ThemeMode.system,
            locale: locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: router,
          );
        },
      ),
    );
  }

  GoRouter? _router;
}
