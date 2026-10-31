import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/regions_cubit.dart';
import 'region_card.dart';

/// Horizontally scrolling showcase of random regions.
class RegionRail extends StatelessWidget {
  const RegionRail({super.key});

  static const double cardWidth = 220;
  static const double cardHeight = 150;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<RegionsCubit, RegionsState>(
      builder: (context, state) {
        if (state is RegionsInitial || state is RegionsLoading) {
          return const _RailShimmer();
        }
        if (state is! RegionsReady || state.regions.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.exploreRegions,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/regions'),
                      child: Text(l10n.seeAll),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: cardHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.regions.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) => SizedBox(
                    width: cardWidth,
                    child: RegionCard(region: state.regions[index]),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RailShimmer extends StatelessWidget {
  const _RailShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: Row(
              children: [
                ShimmerBox(width: 150, height: 18, borderRadius: 6),
                Spacer(),
                ShimmerBox(width: 56, height: 16, borderRadius: 6),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: RegionRail.cardHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => SizedBox(
                width: RegionRail.cardWidth,
                child: const ShimmerBox(borderRadius: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
