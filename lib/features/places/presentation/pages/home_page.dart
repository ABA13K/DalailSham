import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/settings/presentation/locale_cubit.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../location/presentation/location_cubit.dart';
import '../bloc/places_bloc.dart';
import '../widgets/category_filter_bar.dart';
import '../widgets/place_card.dart';
import '../widgets/place_stories_bar.dart';

/// Feed of nearby places: resolves location, then loads and filters places.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      child: Scaffold(
        appBar: AppBar(
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
              tooltip: l10n.localeSwitchTooltip,
              icon: const Icon(Icons.translate_rounded),
              onPressed: () => context.read<LocaleCubit>().toggle(),
            ),
            IconButton(
              tooltip: l10n.retry,
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () =>
                  context.read<PlacesBloc>().add(const PlacesRefreshed()),
            ),
          ],
        ),
        body: Column(
          children: [
            BlocBuilder<PlacesBloc, PlacesState>(
              buildWhen: (previous, current) =>
                  previous.allPlaces != current.allPlaces,
              builder: (context, state) => PlaceStoriesBar(
                places: state.allPlaces,
                onPlaceTap: (place) => context.push('/place', extra: place),
              ),
            ),
            Padding(
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
                          onPressed: () {
                            _searchController.clear();
                            context.read<PlacesBloc>().add(
                              const PlaceSearchQueryChanged(''),
                            );
                            setState(() {});
                          },
                        ),
                ),
                onChanged: (value) {
                  context.read<PlacesBloc>().add(
                    PlaceSearchQueryChanged(value),
                  );
                  setState(() {});
                },
              ),
            ),
            BlocBuilder<PlacesBloc, PlacesState>(
              buildWhen: (previous, current) =>
                  previous.category != current.category,
              builder: (context, state) => CategoryFilterBar(
                selected: state.category,
                onSelected: (category) => context.read<PlacesBloc>().add(
                  PlaceCategoryFiltered(category),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(child: _PlacesBody(searchController: _searchController)),
          ],
        ),
      ),
    );
  }
}

class _PlacesBody extends StatelessWidget {
  const _PlacesBody({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, locationState) {
        if (locationState is LocationFailureState &&
            context.read<PlacesBloc>().state.allPlaces.isEmpty) {
          return switch (locationState.failure) {
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
          };
        }

        return BlocBuilder<PlacesBloc, PlacesState>(
          builder: (context, state) {
            switch (state.status) {
              case PlacesStatus.initial:
              case PlacesStatus.loading:
                if (state.allPlaces.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(l10n.locationLoading),
                      ],
                    ),
                  );
                }
                return const _PlacesList();

              case PlacesStatus.success:
                if (state.visiblePlaces.isEmpty) {
                  return _EmptyState(
                    icon: state.hasFilters
                        ? Icons.search_off_rounded
                        : Icons.location_off_rounded,
                    message: l10n.placesEmpty,
                  );
                }
                return const _PlacesList();

              case PlacesStatus.failure:
                if (state.allPlaces.isNotEmpty) {
                  return const _PlacesList();
                }
                return _EmptyState(
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
                );
            }
          },
        );
      },
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
      builder: (context, state) => RefreshIndicator(
        onRefresh: () async =>
            context.read<PlacesBloc>().add(const PlacesRefreshed()),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
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
