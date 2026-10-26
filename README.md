# Dali Alsham — دلي الشام

A Flutter app that advertises and discovers **places around you**: restaurants,
cafés, shops, hotels, attractions, pharmacies, fuel stations and banks — with
distance, opening hours and one-tap directions.

- **Architecture:** Clean Architecture (presentation / domain / data), feature-first
- **State management:** Bloc / Cubit (`flutter_bloc`)
- **Data:** OpenStreetMap Overpass REST API (free, no API key)
- **Routing:** `go_router`
- **DI:** `get_it`
- **Localization:** AR (RTL, default) + EN, `flutter gen-l10n`

## Run

```bash
flutter pub get
flutter gen-l10n
flutter run
```

## Test / analyze

```bash
flutter analyze
flutter test
```

## Project structure

```
lib/
├── main.dart                  # entry: DI init → runApp
├── app/
│   ├── app.dart               # MaterialApp.router, providers, locale
│   ├── router.dart            # go_router route table
│   └── splash_page.dart       # animated branded launch screen
├── core/                      # shared, feature-agnostic code
│   ├── error/                 # exceptions, failures, Result<T>
│   ├── usecases/              # UseCase<T, Params> contract
│   ├── network/               # Dio client + API constants
│   ├── theme/                 # Material 3 light/dark theme
│   ├── utils/                 # haversine distance, distance formatter
│   └── settings/              # locale preference (domain/data/presentation)
├── features/
│   ├── location/              # current GPS position
│   │   ├── domain/            # UserLocation, repository contract, use case
│   │   ├── data/              # Geolocator implementation
│   │   └── presentation/      # LocationCubit
│   ├── onboarding/            # first-run intro (photo + glass cards)
│   │   ├── domain/            # OnboardingRepository contract
│   │   ├── data/              # SharedPreferences completion flag
│   │   └── presentation/      # OnboardingPage (3-step PageView)
│   └── places/                # nearby places feed
│       ├── domain/            # Place entity, PlaceCategory, repository, use case
│       ├── data/              # Overpass datasource, PlaceModel, repository impl
│       └── presentation/      # PlacesBloc, pages, widgets
├── l10n/                      # app_en.arb, app_ar.arb + generated code
└── di/injection.dart          # get_it registrations
```

## Layer rules (dependency flow)

```
presentation  →  domain  ←  data
```

- **domain** is pure Dart (no Flutter imports): entities, repository contracts
  (`abstract interface class`), use cases returning `Result<T>`.
- **data** implements domain contracts, talks to Dio/geolocator/SharedPreferences,
  throws `AppException`s.
- **presentation** (Bloc/Cubit + widgets) never sees DTOs or Dio — only entities
  and `Failure`s.
- `Result<T>` (`Success` / `FailureResult`) keeps the domain free of exceptions;
  `failureFromException()` maps data-layer exceptions to failures at the repo boundary.

## Request flow (places feed)

1. `LocationCubit.locate()` → `GetCurrentLocation` use case → `GeolocatorLocationRepository`
2. On `LocationReady`, `HomePage` dispatches `PlacesRequested` to `PlacesBloc`
3. `PlacesBloc` → `GetNearbyPlaces` use case → `PlacesRepositoryImpl`
4. Data: `OverpassPlacesRemoteDataSource` (Overpass QL query) → `PlaceModel`s
5. Repo computes haversine distance, sorts nearest-first, returns `Result<List<Place>>`
6. Bloc emits `PlacesState`; category chips and search filter client-side
7. `PlaceCard` → `context.push('/place', extra: place)` → `PlaceDetailsPage`
   (directions / call / website via `url_launcher`)

## Adding a new feature

1. `lib/features/<feature>/domain/` — entity, repository contract, use case
2. `lib/features/<feature>/data/` — DTO + remote/local datasource + repo impl
3. `lib/features/<feature>/presentation/` — Bloc/Cubit + pages/widgets
4. Register data + domain objects in `lib/di/injection.dart`
5. Add strings to `lib/l10n/app_en.arb` and `app_ar.arb`, run `flutter gen-l10n`
