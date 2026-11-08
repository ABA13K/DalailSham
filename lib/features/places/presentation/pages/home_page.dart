import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/app_bottom_bar.dart';
import '../../../../app/app_drawer.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/settings/presentation/token_cubit.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/option_sheet.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../banners/presentation/cubit/banners_cubit.dart';
import '../../../categories/presentation/cubit/categories_cubit.dart';
import '../../../categories/presentation/widgets/category_pills.dart';
import '../../../location/presentation/location_cubit.dart';
import '../../../regions/domain/entities/region.dart';
import '../../../regions/presentation/cubit/regions_cubit.dart';
import '../../../regions/presentation/widgets/region_rail.dart';
import '../../../services/domain/entities/service_scope.dart';
import '../../../services/domain/entities/service_summary.dart';
import '../../../services/presentation/cubit/nearby_cubit.dart';
import '../../../services/presentation/cubit/services_cubit.dart';
import '../../../services/presentation/cubit/top_rated_cubit.dart';
import '../../../services/presentation/widgets/nearby_rail.dart';
import '../../../services/presentation/widgets/service_card.dart';
import '../../../services/presentation/widgets/top_rated_rail.dart';
import '../../../stories/domain/entities/story.dart';
import '../../../stories/domain/entities/story_feed.dart';
import '../../../stories/domain/usecases/get_service_story_feed.dart';
import '../../../stories/presentation/cubit/story_feed_cubit.dart';
import '../../../stories/presentation/pages/service_stories_page.dart';
import '../../../stories/presentation/widgets/story_strip.dart';
import '../../../tutorial/presentation/feature_tour.dart';
import '../../../tutorial/presentation/tutorial_cubit.dart';
import '../../../vendor/domain/repositories/vendor_picker_repository.dart';
import '../bloc/places_bloc.dart';
import '../cubit/stories_seen_cubit.dart';
import 'stories_page.dart';
import '../widgets/advertise_bar.dart';
import '../widgets/place_stories_bar.dart';

/// Feed of nearby services: resolves location, then loads and filters them.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const _searchDebounce = Duration(milliseconds: 300);

  /// How far a tap on a story follows the service's archive for pages. Beyond
  /// this the viewer runs on what was already gathered.
  static const _archivePageCap = 3;

  final _searchController = TextEditingController();
  final _appBarKey = GlobalKey();
  final _storiesKey = GlobalKey();
  final _adsKey = GlobalKey();
  final _searchKey = GlobalKey();
  Timer? _searchTimer;
  String? _feedLocale;
  String _query = '';

  /// A tap that is still gathering the service's stories. A second one while it
  /// waits would open two viewers over the same set.
  bool _storyOpening = false;

  /// The category whose pill is pressed, or null while the list holds every
  /// place near the user.
  int? _categoryId;

  /// The region picked from the header, with the name it is shown under. Only
  /// one of the two filters is ever active, so the list never hides behind two.
  int? _regionId;
  String? _regionName;

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
    // The stories listing needs no token and no location; only the language of
    // its labels changes.
    context.read<StoryFeedCubit>().load(locale);
    _loadServices();
  }

  /// The three service sections depend on the stored token and on the location,
  /// which the backend uses to sort and label distances. The list under the
  /// search field is asked for on the same terms, read page by page.
  void _loadServices() {
    final location = context.read<LocationCubit>().state;
    final locale = Localizations.localeOf(context).languageCode;
    final authenticated = context.read<TokenCubit>().state != null;
    final userLat = location is LocationReady ? location.latitude : null;
    final userLng = location is LocationReady ? location.longitude : null;

    context.read<TopRatedCubit>().load(
      locale: locale,
      authenticated: authenticated,
      userLat: userLat,
      userLng: userLng,
    );
    context.read<NearbyCubit>().load(
      locale: locale,
      authenticated: authenticated,
      userLat: userLat,
      userLng: userLng,
    );
    _loadFeed();
  }

  /// The list under the search field: every place near the user, or the ones
  /// inside the pressed category pill or the region picked from the header.
  void _loadFeed() {
    final location = context.read<LocationCubit>().state;
    final region = _regionId;
    final category = _categoryId;
    final scope = region != null
        ? ServiceScope.region
        : category != null
        ? ServiceScope.category
        : ServiceScope.nearby;
    context.read<ServicesCubit>().load(
      scope: scope,
      scopeId: region ?? category,
      locale: Localizations.localeOf(context).languageCode,
      authenticated: context.read<TokenCubit>().state != null,
      userLat: location is LocationReady ? location.latitude : null,
      userLng: location is LocationReady ? location.longitude : null,
    );
  }

  /// The stories row. The services' own stories take it as soon as the public
  /// listing has any; while it has none the nearby places stand in, so the
  /// section is never an empty row and a place profile stays reachable.
  Widget _storiesStrip() {
    return BlocBuilder<StoryFeedCubit, StoryFeedState>(
      buildWhen: (previous, current) =>
          previous.status != current.status ||
          previous.stories != current.stories,
      builder: (context, feed) {
        final waiting =
            feed.status == StoryFeedStatus.initial ||
            feed.status == StoryFeedStatus.loading;
        if (!waiting && feed.stories.isEmpty) {
          return BlocBuilder<PlacesBloc, PlacesState>(
            buildWhen: (previous, current) =>
                previous.allPlaces != current.allPlaces,
            builder: (context, state) =>
                BlocBuilder<StoriesSeenCubit, Set<String>>(
                  buildWhen: (previous, current) => previous != current,
                  builder: (context, viewedIds) => PlaceStoriesBar(
                    places: state.allPlaces,
                    viewedIds: viewedIds,
                    onStoryTap: (place, index) => context.push(
                      '/stories',
                      extra: StoriesArgs(
                        places: state.allPlaces
                            .take(PlaceStoriesBar.maxStories)
                            .toList(),
                        initialIndex: index,
                      ),
                    ),
                  ),
                ),
          );
        }

        return BlocBuilder<StoriesSeenCubit, Set<String>>(
          buildWhen: (previous, current) => previous != current,
          builder: (context, viewedIds) => StoryStrip(
            status: feed.status,
            stories: feed.stories,
            viewedIds: viewedIds,
            onStoryTap: (index) =>
                _openStory(feed.stories[index], feed.stories),
          ),
        );
      },
    );
  }

  /// Tapping a story runs everything its service posted, not only the page the
  /// strip happens to show: the archive behind it is gathered first and the
  /// viewer opens on the story that was tapped. A story that names no service,
  /// or an archive that will not answer, plays the strip's own set instead, so
  /// a tap is never a dead one.
  Future<void> _openStory(Story tapped, List<Story> fromFeed) async {
    if (_storyOpening) return;

    final service = tapped.service;
    if (service == null) {
      _showStories(fromFeed, tapped);
      return;
    }

    _storyOpening = true;
    try {
      final archive = await _wholeArchive(service.id);
      if (!mounted) return;
      if (archive.isEmpty) {
        _showStories(fromFeed, tapped);
        return;
      }
      // The strip held this story a moment ago; an archive that no longer does
      // still opens where the reader pointed.
      _showStories(
        archive.any((story) => story.id == tapped.id) ? archive : [
          tapped,
          ...archive,
        ],
        tapped,
      );
    } finally {
      _storyOpening = false;
    }
  }

  /// One service's stories, page by page, as long as it keeps offering another
  /// page and none of them repeats. A page that will not answer ends the walk
  /// with what came before it.
  Future<List<Story>> _wholeArchive(int serviceId) async {
    final locale = Localizations.localeOf(context).languageCode;
    final getServiceStories = getIt<GetServiceStoryFeed>();
    final gathered = <Story>[];
    final seenIds = <int>{};
    int? page = 1;

    for (var taken = 0; page != null && taken < _archivePageCap; taken++) {
      final result = await getServiceStories(
        ServiceStoryFeedParams(serviceId: serviceId, locale: locale, page: page),
      );
      final feed = result.fold<StoryFeed?>(
        (_) => null,
        (feed) => feed,
      );
      if (feed == null) break;

      for (final story in feed.stories) {
        if (seenIds.add(story.id)) gathered.add(story);
      }
      page = feed.hasMore ? (feed.nextPage ?? page + 1) : null;
    }
    return gathered;
  }

  /// The viewer over [stories], opening on [tapped] wherever it landed.
  void _showStories(List<Story> stories, Story tapped) {
    final index = stories.indexWhere((story) => story.id == tapped.id);
    context.push(
      '/service-stories',
      extra: ServiceStoriesArgs(
        stories: stories,
        initialIndex: index < 0 ? 0 : index,
      ),
    );
  }

  /// A pill carries its category with it, so choosing one reloads only the list
  /// under the search field and leaves the rails above untouched. It also hands
  /// the header back to the whole city, since one list cannot hold two filters.
  void _selectCategory(int? categoryId) {
    if (categoryId == _categoryId) return;
    setState(() {
      _categoryId = categoryId;
      if (categoryId != null) {
        _regionId = null;
        _regionName = null;
      }
    });
    _loadFeed();
  }

  /// The header is the city, or the region the list is currently narrowed to.
  /// Pressing it again and choosing the same region lifts the filter.
  Future<void> _pickRegion() async {
    final l10n = AppLocalizations.of(context);
    final region = await showOptionSheet<Region>(
      context,
      title: l10n.chooseRegion,
      label: (region) => region.name,
      load: _loadRegions,
    );
    if (!mounted || region == null) return;

    final lifted = region.id == _regionId;
    setState(() {
      _regionId = lifted ? null : region.id;
      _regionName = lifted ? null : region.name;
      if (!lifted) _categoryId = null;
    });
    _loadFeed();
  }

  Future<List<Region>> _loadRegions(String locale, String? query) async {
    final result = await getIt<VendorPickerRepository>().regions(
      locale: locale,
      query: query,
    );
    return result.fold((failure) => throw failure, (regions) => regions);
  }

  /// The backend has no notifications endpoint yet, so the bell only reports
  /// that there is nothing to read.
  void _showNotifications() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const ValueKey('notifications-empty'),
          content: Text(l10n.notificationsEmpty),
        ),
      );
  }

  /// What the list under the search field currently holds.
  String _feedTitle(AppLocalizations l10n) {
    final region = _regionId;
    if (region != null) return _regionName ?? l10n.homeTitle;
    final categoryId = _categoryId;
    if (categoryId == null) return l10n.homeTitle;
    final shown = context.read<CategoriesCubit>().state;
    if (shown is CategoriesReady) {
      for (final category in shown.categories) {
        if (category.id == categoryId) return category.name;
      }
    }
    return l10n.homeTitle;
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
      setState(() => _query = value.trim());
    });
  }

  void _submitSearch(String value) {
    _searchTimer?.cancel();
    final query = value.trim();
    if (query.isEmpty) return;
    // Typing narrows what the feed already holds; the keyboard action asks the
    // backend, which also searches services the feed never loaded.
    context.push('/search', extra: query);
  }

  void _clearSearch() {
    _searchTimer?.cancel();
    _searchController.clear();
    setState(() => _query = '');
  }

  Future<void> _refresh() async {
    final showcase = context.read<CategoriesCubit>();
    final categoriesRefresh = showcase.reload();
    context.read<RegionsCubit>().reload();
    context.read<BannersCubit>().reload();
    // The strip is part of what the reader pulls for. Asked in the same
    // language it keeps the stories on screen until the new page lands.
    final storiesRefresh = context
        .read<StoryFeedCubit>()
        .load(Localizations.localeOf(context).languageCode);
    _loadServices();
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
    await Future.wait([categoriesRefresh, storiesRefresh]);
    if (!mounted) return;
    // A refresh can hand back a different showcase, and a category whose pill is
    // gone has nothing left to press, so the list falls back to the nearby one.
    final shown = showcase.state;
    final kept =
        shown is CategoriesReady &&
        shown.categories.any((category) => category.id == _categoryId);
    if (_categoryId != null && !kept) _selectCategory(null);
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
              _loadServices();
            }
          },
        ),
        BlocListener<TokenCubit, String?>(
          listener: (context, token) => _loadServices(),
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
                title: InkWell(
                  key: const ValueKey('header-city'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: _pickRegion,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 6,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                _regionName ?? l10n.cityTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge,
                              ),
                            ),
                            const Icon(Icons.expand_more_rounded, size: 22),
                          ],
                        ),
                        Text(
                          l10n.appTagline,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    key: const ValueKey('header-notifications'),
                    tooltip: l10n.notificationsTitle,
                    icon: const Icon(Icons.notifications_none_rounded),
                    onPressed: _showNotifications,
                  ),
                  IconButton(
                    tooltip: l10n.retry,
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: _refresh,
                  ),
                ],
              ),
              bottomNavigationBar: const AppBottomBar(),
              body: CenteredContent(
                child: RefreshIndicator(
                  onRefresh: () async => _refresh(),
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      const SliverToBoxAdapter(child: _LocationNotice()),
                      SliverToBoxAdapter(
                        child: Padding(
                          key: _searchKey,
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  key: const ValueKey('feed-filters'),
                                  tooltip: l10n.filtersTitle,
                                  icon: const Icon(Icons.filter_alt_rounded),
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimaryContainer,
                                  onPressed: () => context.push('/search'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: l10n.searchHint,
                                    prefixIcon: const Icon(
                                      Icons.search_rounded,
                                    ),
                                    suffixIcon: _searchController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            key: const ValueKey(
                                              'search-clear-feed',
                                            ),
                                            icon: const Icon(
                                              Icons.clear_rounded,
                                            ),
                                            onPressed: _clearSearch,
                                          ),
                                  ),
                                  onChanged: _onSearchChanged,
                                  onSubmitted: _submitSearch,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(child: AdvertiseBar(key: _adsKey)),
                      SliverToBoxAdapter(
                        child: KeyedSubtree(
                          key: _storiesKey,
                          child: _storiesStrip(),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: CategoryPills(
                          selectedId: _categoryId,
                          onSelect: _selectCategory,
                        ),
                      ),
                      const SliverToBoxAdapter(child: RegionRail()),
                      const SliverToBoxAdapter(child: TopRatedRail()),
                      const SliverToBoxAdapter(child: NearbyRail()),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                          child: Text(
                            _feedTitle(l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      _ServicesSliver(query: _query, onRetry: _loadServices),
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

/// Why the stories strip stayed empty when the app could not read the position.
/// The service listing works without it, so this only explains the missing half.
class _LocationNotice extends StatelessWidget {
  const _LocationNotice();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        if (state is! LocationFailureState) return const SizedBox.shrink();
        final message = switch (state.failure) {
          LocationPermissionFailure() => l10n.locationPermissionMessage,
          LocationServiceDisabledFailure() => l10n.locationServiceDisabled,
          _ => null,
        };
        if (message == null) return const SizedBox.shrink();

        final colors = Theme.of(context).colorScheme;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsetsDirectional.only(start: 12, end: 4),
          decoration: BoxDecoration(
            color: colors.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 18,
                color: colors.onErrorContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('location-settings'),
                onPressed: Geolocator.openAppSettings,
                child: Text(l10n.openSettings),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The list under the search field: the services closest to the user, or the
/// ones inside the category pill or the header region picked above it.
class _ServicesSliver extends StatelessWidget {
  const _ServicesSliver({required this.query, required this.onRetry});

  final String query;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ServicesCubit, ServicesState>(
      builder: (context, state) {
        final visible = _matching(state.services, query);
        final cubit = context.read<ServicesCubit>();

        switch (state.status) {
          case ServicesStatus.initial:
          case ServicesStatus.loading:
            if (state.services.isEmpty) return const _FeedShimmer();
            return _FeedList(
              services: visible,
              state: state,
              cubit: cubit,
              asksForMore: state.hasMore && query.isEmpty,
            );

          case ServicesStatus.failure:
            if (state.services.isNotEmpty) {
              return _FeedList(
                services: visible,
                state: state,
                cubit: cubit,
                asksForMore: state.hasMore && query.isEmpty,
              );
            }
            return SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyState(
                icon: Icons.error_outline_rounded,
                message: l10n.servicesError,
                action: FilledButton.icon(
                  key: const ValueKey('feed-retry'),
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
            );

          case ServicesStatus.ready:
            if (visible.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  icon: query.isEmpty
                      ? Icons.storefront_outlined
                      : Icons.search_off_rounded,
                  message: query.isEmpty
                      ? l10n.servicesEmpty
                      : l10n.searchEmpty,
                ),
              );
            }
            return _FeedList(
              services: visible,
              state: state,
              cubit: cubit,
              asksForMore: state.hasMore && query.isEmpty,
            );
        }
      },
    );
  }
}

/// Services whose name, category or region carries the typed text.
List<ServiceSummary> _matching(List<ServiceSummary> services, String query) {
  if (query.isEmpty) return services;
  final needle = query.toLowerCase();
  return services
      .where(
        (service) =>
            service.name.toLowerCase().contains(needle) ||
            (service.categoryName?.toLowerCase().contains(needle) ?? false) ||
            (service.regionName?.toLowerCase().contains(needle) ?? false),
      )
      .toList();
}

/// The cards, with the page after them asked for by the last row.
class _FeedList extends StatelessWidget {
  const _FeedList({
    required this.services,
    required this.state,
    required this.cubit,
    required this.asksForMore,
  });

  final List<ServiceSummary> services;
  final ServicesState state;
  final ServicesCubit cubit;

  /// A narrowed list is not a page the feed can ask more of, so the button only
  /// follows the whole list.
  final bool asksForMore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      sliver: SliverList.builder(
        itemCount: services.length + (asksForMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= services.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FilledButton.tonal(
                key: const ValueKey('feed-load-more'),
                onPressed: state.isLoadingMore ? null : () => cubit.loadMore(),
                child: state.isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.loadMore),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ServiceCard(service: services[index]),
          );
        },
      ),
    );
  }
}

class _FeedShimmer extends StatelessWidget {
  const _FeedShimmer();

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      sliver: SliverList.separated(
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (_, _) => const _ServiceCardShimmer(),
      ),
    );
  }
}

class _ServiceCardShimmer extends StatelessWidget {
  const _ServiceCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const ShimmerBox(width: 60, height: 60, borderRadius: 12),
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
