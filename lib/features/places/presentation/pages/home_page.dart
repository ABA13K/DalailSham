import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_drawer.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../banners/presentation/cubit/banners_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/widgets/category_rail.dart';
import '../../../location/presentation/location_cubit.dart';
import '../../../regions/presentation/cubit/regions_cubit.dart';
import '../../../regions/presentation/widgets/region_rail.dart';
import '../../../tutorial/presentation/feature_tour.dart';
import '../../../tutorial/presentation/tutorial_cubit.dart';
import '../bloc/places_bloc.dart';
import '../cubit/stories_seen_cubit.dart';
import 'stories_page.dart';
import '../widgets/advertise_bar.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/place_card.dart';
import '../widgets/place_stories_bar.dart';

/// Feed of nearby places: resolves location, then loads and filters places.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const _searchDebounce = Duration(milliseconds: 300);

  final _searchController = TextEditingController();
  final _appBarKey = GlobalKey();
  final _storiesKey = GlobalKey();
  final _adsKey = GlobalKey();
  final _searchKey = GlobalKey();
  Timer? _searchTimer;
  String? _feedLocale;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Request location only once the feed is visible, so the permission
    // prompt appears with in-app context rather than over the splash.
    final location = context.read<LocationCubit>().state;
    if (location is LocationInitial) {
      context.read<LocationCubit>().locate();
      return;
    }
    // Location can resolve before this page starts listening for state changes.
    final places = context.read<PlacesBloc>().state;
    if (location is LocationReady && places.status == PlacesStatus.initial) {
      context.read<PlacesBloc>().add(
        PlacesRequested(
          latitude: location.latitude,
          longitude: location.longitude,
        ),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // Picks up permission or location services granted outside the app.
      context.read<LocationCubit>().retryIfAccessGranted();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context).languageCode;
    if (locale == _feedLocale) return;
    _feedLocale = locale;
    context.read<CategoriesCubit>().load(locale);
    context.read<RegionsCubit>().load(locale);
    context.read<BannersCubit>().load(locale);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Waits for a pause in typing before querying, so a fast typist does not
  /// trigger a request per character.
  void _onSearchChanged(String value) {
    setState(() {});
    _searchTimer?.cancel();
    _searchTimer = Timer(_searchDebounce, () {
      if (!mounted) return;
      context.read<PlacesBloc>().add(PlaceSearchQueryChanged(value));
    });
  }

  void _submitSearch(String value) {
    _searchTimer?.cancel();
    context.read<PlacesBloc>().add(PlaceSearchQueryChanged(value));
  }

  void _clearSearch() {
    _searchTimer?.cancel();
    _searchController.clear();
    context.read<PlacesBloc>().add(const PlaceSearchQueryChanged(''));
    setState(() {});
  }

  void _refresh() {
    context.read<CategoriesCubit>().reload();
    context.read<RegionsCubit>().reload();
    context.read<BannersCubit>().reload();
    final location = context.read<LocationCubit>().state;
    switch (location) {
      case LocationReady():
        context.read<PlacesBloc>().add(const PlacesRefreshed());
      case LocationInitial():
      case LocationFailureState():
        context.read<LocationCubit>().locate();
      case LocationLoading():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return MultiBlocListener(
      listeners: [
        BlocListener<LocationCubit, LocationState>(
          listener: (context, state) {
            if (state is LocationReady) {
              context.read<PlacesBloc>().add(
                PlacesRequested(
                  latitude: state.latitude,
                  longitude: state.longitude,
                ),
              );
            }
          },
        ),
        BlocListener<PlacesBloc, PlacesState>(
          listenWhen: (previous, current) =>
              current.status == PlacesStatus.failure &&
              previous.status != PlacesStatus.failure,
          listener: (context, state) {
            final message = state.failure == null
                ? l10n.placesError
                : switch (state.failure!) {
                    LocationPermissionFailure() =>
                      l10n.locationPermissionMessage,
                    LocationServiceDisabledFailure() =>
                      l10n.locationServiceDisabled,
                    _ => l10n.placesError,
                  };
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(content: Text(message)));
          },
        ),
      ],
      child: BlocBuilder<TutorialCubit, bool?>(
        builder: (context, tutorialCompleted) => Stack(
          fit: StackFit.expand,
          children: [
            Scaffold(
              drawer: const AppDrawer(),
              appBar: AppBar(
                key: _appBarKey,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.homeTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      l10n.appTagline,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: l10n.retry,
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _refresh,
                  ),
                ],
              ),
              body: CenteredContent(
                child: RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: BlocBuilder<PlacesBloc, PlacesState>(
                          buildWhen: (previous, current) =>
                              previous.isDemoData != current.isDemoData,
                          builder: (context, state) => state.isDemoData
                              ? const _DemoDataBanner()
                              : const SizedBox.shrink(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: KeyedSubtree(
                          key: _storiesKey,
                          child: BlocBuilder<PlacesBloc, PlacesState>(
                            buildWhen: (previous, current) =>
                                previous.allPlaces != current.allPlaces,
                            builder: (context, state) =>
                                BlocBuilder<StoriesSeenCubit, Set<String>>(
                                  buildWhen: (previous, current) =>
                                      previous != current,
                                  builder: (context, viewedIds) =>
                                      PlaceStoriesBar(
                                        places: state.allPlaces,
                                        viewedIds: viewedIds,
                                        onStoryTap: (place, index) =>
                                            context.push(
                                              '/stories',
                                              extra: StoriesArgs(
                                                places: state.allPlaces
                                                    .take(
                                                      PlaceStoriesBar
                                                          .maxStories,
                                                    )
                                                    .toList(),
                                                initialIndex: index,
                                              ),
                                            ),
                                      ),
                                ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: AdvertiseBar(key: _adsKey)),
                      const SliverToBoxAdapter(child: CategoryRail()),
                      const SliverToBoxAdapter(child: RegionRail()),
                      SliverToBoxAdapter(
                        child: Padding(
                          key: _searchKey,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: l10n.searchHint,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear_rounded),
                                      onPressed: _clearSearch,
                                    ),
                            ),
                            onChanged: _onSearchChanged,
                            onSubmitted: _submitSearch,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: BlocBuilder<PlacesBloc, PlacesState>(
                          buildWhen: (previous, current) =>
                              previous.category != current.category,
                          builder: (context, state) => CategoryFilterBar(
                            selected: state.category,
                            onSelected: (category) => context
                                .read<PlacesBloc>()
                                .add(PlaceCategoryFiltered(category)),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      const _PlacesSliver(),
                    ],
                  ),
                ),
              ),
            ),
            if (tutorialCompleted == false)
              FeatureTour(
                steps: _tourSteps(l10n),
                onFinished: () => context.read<TutorialCubit>().complete(),
              ),
          ],
        ),
      ),
    );
  }

  List<TourStep> _tourSteps(AppLocalizations l10n) => [
    TourStep(
      targetKey: _storiesKey,
      title: l10n.tutorialStoriesTitle,
      body: l10n.tutorialStoriesBody,
    ),
    TourStep(
      targetKey: _adsKey,
      title: l10n.tutorialAdsTitle,
      body: l10n.tutorialAdsBody,
    ),
    TourStep(
      targetKey: _searchKey,
      title: l10n.tutorialSearchTitle,
      body: l10n.tutorialSearchBody,
    ),
    TourStep(
      targetKey: _appBarKey,
      title: l10n.tutorialMenuTitle,
      body: l10n.tutorialMenuBody,
    ),
  ];
}

class _PlacesSliver extends StatelessWidget {
  const _PlacesSliver();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationFailureState &&
            context.read<PlacesBloc>().state.allPlaces.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: switch (locationState.failure) {
              LocationPermissionFailure() => _EmptyState(
                icon: Icons.location_off_rounded,
                message: l10n.locationPermissionMessage,
                action: FilledButton.icon(
                  onPressed: () => Geolocator.openAppSettings(),
                  icon: const Icon(Icons.settings_rounded),
                  label: Text(l10n.openSettings),
                ),
              ),
              LocationServiceDisabledFailure() => _EmptyState(
                icon: Icons.location_off_rounded,
                message: l10n.locationServiceDisabled,
                action: FilledButton.icon(
                  onPressed: () => Geolocator.openAppSettings(),
                  icon: const Icon(Icons.settings_rounded),
                  label: Text(l10n.openSettings),
                ),
              ),
              _ => _EmptyState(
                icon: Icons.error_outline_rounded,
                message: l10n.placesError,
                action: FilledButton.icon(
                  onPressed: () => context.read<LocationCubit>().locate(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
            },
          );
        }

        return BlocBuilder<PlacesBloc, PlacesState>(
          builder: (context, state) {
            switch (state.status) {
              case PlacesStatus.initial:
              case PlacesStatus.loading:
                if (state.allPlaces.isEmpty) {
                  return const _PlacesShimmer();
                }
                return const _PlacesList();

              case PlacesStatus.success:
                if (state.visiblePlaces.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      icon: state.hasFilters
                          ? Icons.search_off_rounded
                          : Icons.location_off_rounded,
                      message: l10n.placesEmpty,
                    ),
                  );
                }
                return const _PlacesList();

              case PlacesStatus.failure:
                if (state.allPlaces.isNotEmpty) {
                  return const _PlacesList();
                }
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    icon: Icons.error_outline_rounded,
                    message: l10n.placesError,
                    action: FilledButton.icon(
                      onPressed: () {
                        final location = context.read<LocationCubit>().state;
                        if (location is LocationReady) {
                          context.read<PlacesBloc>().add(
                            PlacesRequested(
                              latitude: location.latitude,
                              longitude: location.longitude,
                            ),
                          );
                        } else {
                          context.read<LocationCubit>().locate();
                        }
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ),
                );
            }
          },
        );
      },
    );
  }
}

class _PlacesShimmer extends StatelessWidget {
  const _PlacesShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const _PlaceCardShimmer(),
      ),
    );
  }
}

class _PlaceCardShimmer extends StatelessWidget {
  const _PlaceCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const ShimmerBox(width: 52, height: 52, borderRadius: 26),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(height: 16, borderRadius: 6),
                const SizedBox(height: 8),
                const FractionallySizedBox(
                  widthFactor: 0.55,
                  alignment: AlignmentDirectional.centerStart,
                  child: ShimmerBox(height: 13, borderRadius: 6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlacesList extends StatelessWidget {
  const _PlacesList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlacesBloc, PlacesState>(
      buildWhen: (previous, current) =>
          previous.visiblePlaces != current.visiblePlaces,
      builder: (context, state) => SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        sliver: SliverList.separated(
          itemCount: state.visiblePlaces.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final place = state.visiblePlaces[index];
            return PlaceCard(
              place: place,
              onTap: () => context.push('/place', extra: place),
            );
          },
        ),
      ),
    );
  }
}

class _DemoDataBanner extends StatelessWidget {
  const _DemoDataBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 18,
            color: theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.demoDataNotice,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message, this.action});

  final IconData icon;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
