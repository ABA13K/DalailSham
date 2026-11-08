import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/settings/presentation/token_cubit.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../favorites/presentation/cubit/favorites_cubit.dart';
import '../../../location/presentation/location_cubit.dart';
import '../../domain/entities/service_scope.dart';
import '../../domain/usecases/get_service_page.dart';
import '../cubit/services_cubit.dart';
import '../widgets/services_result_list.dart';

/// Navigation payload for [ServicesPage].
class ServicesRouteArgs {
  const ServicesRouteArgs({required this.scope, required this.title, this.id});

  final ServiceScope scope;
  final String title;

  /// Category or region id; unused for [ServiceScope.favorites].
  final int? id;
}

/// The services published inside one category, region or the user's favorites,
/// loaded page by page.
class ServicesPage extends StatelessWidget {
  const ServicesPage({
    super.key,
    required this.scope,
    required this.title,
    this.scopeId,
  });

  final ServiceScope scope;
  final String title;
  final int? scopeId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final location = context.read<LocationCubit>().state;
    final userLat = location is LocationReady ? location.latitude : null;
    final userLng = location is LocationReady ? location.longitude : null;
    final isFavorites = scope == ServiceScope.favorites;
    final hasToken = context.select<TokenCubit, bool>(
      (cubit) => cubit.state != null,
    );

    void fetch(ServicesCubit cubit) => cubit.load(
      scope: scope,
      scopeId: scopeId,
      locale: locale,
      authenticated: hasToken,
      userLat: userLat,
      userLng: userLng,
    );

    return BlocProvider(
      create: (_) {
        final cubit = ServicesCubit(getIt<GetServicePage>());
        fetch(cubit);
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: BlocListener<TokenCubit, String?>(
          // Signing in from the drawer replaces the gate, so the favorites the
          // user just came to read are fetched without another tap.
          listenWhen: (previous, current) => isFavorites && current != previous,
          listener: (context, token) => fetch(context.read<ServicesCubit>()),
          child: CenteredContent(
            child: BlocBuilder<ServicesCubit, ServicesState>(
              builder: (context, state) => switch (state.status) {
                ServicesStatus.initial ||
                ServicesStatus.loading => const ServicesShimmer(),
                ServicesStatus.failure => ServicesMessage(
                  icon: isFavorites && !hasToken
                      ? Icons.lock_outline_rounded
                      : Icons.cloud_off_rounded,
                  message: isFavorites && !hasToken
                      ? l10n.favoritesNeedLogin
                      : l10n.placesError,
                  action: FilledButton.icon(
                    onPressed: () => isFavorites && !hasToken
                        ? context.push('/login')
                        : fetch(context.read<ServicesCubit>()),
                    icon: Icon(
                      isFavorites && !hasToken
                          ? Icons.login_rounded
                          : Icons.refresh_rounded,
                    ),
                    label: Text(
                      isFavorites && !hasToken ? l10n.signIn : l10n.retry,
                    ),
                  ),
                ),
                ServicesStatus.ready => _ServicesBody(
                  state: state,
                  isFavorites: isFavorites,
                ),
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Either the list of services or the message that replaces an empty one.
///
/// Watching [FavoritesCubit] lets a service disappear from the favorites page
/// the moment its heart is turned off.
class _ServicesBody extends StatelessWidget {
  const _ServicesBody({required this.state, required this.isFavorites});

  final ServicesState state;
  final bool isFavorites;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final services = isFavorites
        ? [
            for (final service in state.services)
              if (context.watch<FavoritesCubit>().isFavorited(service)) service,
          ]
        : state.services;

    if (services.isEmpty) {
      return ServicesMessage(
        icon: isFavorites
            ? Icons.favorite_border_rounded
            : Icons.storefront_outlined,
        message: isFavorites ? l10n.favoritesEmpty : l10n.servicesEmpty,
      );
    }
    return ServicesResultList(
      services: services,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      onLoadMore: () => context.read<ServicesCubit>().loadMore(),
    );
  }
}
