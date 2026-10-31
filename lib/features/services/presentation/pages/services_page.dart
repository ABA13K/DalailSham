import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../location/presentation/location_cubit.dart';
import '../../domain/entities/service_scope.dart';
import '../../domain/usecases/get_service_page.dart';
import '../cubit/services_cubit.dart';
import '../widgets/service_card.dart';

/// Navigation payload for [ServicesPage].
class ServicesRouteArgs {
  const ServicesRouteArgs({
    required this.scope,
    required this.id,
    required this.title,
  });

  final ServiceScope scope;
  final int id;
  final String title;
}

/// The services published inside one category or region, loaded page by page.
class ServicesPage extends StatelessWidget {
  const ServicesPage({
    super.key,
    required this.scope,
    required this.scopeId,
    required this.title,
  });

  final ServiceScope scope;
  final int scopeId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final location = context.read<LocationCubit>().state;
    final userLat = location is LocationReady ? location.latitude : null;
    final userLng = location is LocationReady ? location.longitude : null;

    void fetch(ServicesCubit cubit) => cubit.load(
      scope: scope,
      scopeId: scopeId,
      locale: locale,
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
        body: CenteredContent(
          child: BlocBuilder<ServicesCubit, ServicesState>(
            builder: (context, state) => switch (state.status) {
              ServicesStatus.initial ||
              ServicesStatus.loading => const _ServicesShimmer(),
              ServicesStatus.failure => _ServicesMessage(
                icon: Icons.cloud_off_rounded,
                message: l10n.placesError,
                action: FilledButton.icon(
                  onPressed: () => fetch(context.read<ServicesCubit>()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              ServicesStatus.ready =>
                state.services.isEmpty
                    ? _ServicesMessage(
                        icon: Icons.storefront_outlined,
                        message: l10n.servicesEmpty,
                      )
                    : _ServicesList(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _ServicesList extends StatelessWidget {
  const _ServicesList({required this.state});

  final ServicesState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverList.builder(
            itemCount: state.services.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ServiceCard(service: state.services[index]),
            ),
          ),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: FilledButton.tonal(
                onPressed: state.isLoadingMore
                    ? null
                    : () => context.read<ServicesCubit>().loadMore(),
                child: state.isLoadingMore
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.loadMore),
              ),
            ),
          ),
      ],
    );
  }
}

class _ServicesShimmer extends StatelessWidget {
  const _ServicesShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 6,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ShimmerBox(height: 84, borderRadius: 12),
    );
  }
}

class _ServicesMessage extends StatelessWidget {
  const _ServicesMessage({
    required this.icon,
    required this.message,
    this.action,
  });

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
