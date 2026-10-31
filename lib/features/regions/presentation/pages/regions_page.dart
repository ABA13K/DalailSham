import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/usecases/get_region_page.dart';
import '../cubit/all_regions_cubit.dart';
import '../widgets/region_card.dart';

/// Full list of regions, loaded page by page.
class RegionsPage extends StatelessWidget {
  const RegionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return BlocProvider(
      create: (_) => AllRegionsCubit(getIt<GetRegionPage>())..load(locale),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            l10n.exploreRegions,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: BlocBuilder<AllRegionsCubit, AllRegionsState>(
            builder: (context, state) => switch (state.status) {
              AllRegionsStatus.initial ||
              AllRegionsStatus.loading => const _RegionsShimmer(),
              AllRegionsStatus.failure => _RegionsMessage(
                icon: Icons.cloud_off_rounded,
                message: l10n.placesError,
                action: FilledButton.icon(
                  onPressed: () =>
                      context.read<AllRegionsCubit>().load(locale),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              AllRegionsStatus.ready =>
                state.regions.isEmpty
                    ? _RegionsMessage(
                        icon: Icons.map_outlined,
                        message: l10n.regionsEmpty,
                      )
                    : _RegionsGrid(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _RegionsGrid extends StatelessWidget {
  const _RegionsGrid({required this.state});

  final AllRegionsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: state.regions.length,
            itemBuilder: (context, index) =>
                RegionCard(region: state.regions[index]),
          ),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: FilledButton.tonal(
                onPressed: state.isLoadingMore
                    ? null
                    : () => context.read<AllRegionsCubit>().loadMore(),
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

class _RegionsShimmer extends StatelessWidget {
  const _RegionsShimmer();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 260,
              mainAxisExtent: 150,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: 6,
            itemBuilder: (_, _) => const ShimmerBox(borderRadius: 18),
          ),
        ),
      ],
    );
  }
}

class _RegionsMessage extends StatelessWidget {
  const _RegionsMessage({
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
