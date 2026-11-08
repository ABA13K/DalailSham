import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/service_review.dart';
import '../cubit/service_reviews_cubit.dart';
import 'service_profile_shared.dart';

/// What readers said: the spread of stars, the order they asked for, and the
/// comments themselves, page by page.
class ServiceReviewsSection extends StatelessWidget {
  const ServiceReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<ServiceReviewsCubit, ServiceReviewsState>(
      builder: (context, state) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ServiceSectionHeader(
            icon: Icons.reviews_rounded,
            title: l10n.sectionReviews,
            trailing: state.status == ServiceReviewsStatus.ready
                ? Text(
                    l10n.reviewsCount(state.summary.totalReviews),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (state.status == ServiceReviewsStatus.ready &&
              state.summary.totalReviews > 0) ...[
            _SummaryCard(summary: state.summary),
            const SizedBox(height: 12),
          ],
          if (state.status != ServiceReviewsStatus.initial) ...[
            _SortPills(sort: state.sort),
            const SizedBox(height: 12),
          ],
          switch (state.status) {
            ServiceReviewsStatus.initial ||
            ServiceReviewsStatus.loading => const _ReviewsShimmer(),
            ServiceReviewsStatus.failure => ServiceSectionMessage(
              icon: Icons.cloud_off_rounded,
              message: l10n.reviewsError,
              action: FilledButton.tonalIcon(
                onPressed: () => context.read<ServiceReviewsCubit>().retry(),
                icon: const Icon(Icons.refresh_rounded),
                label: Text(l10n.retry),
              ),
            ),
            ServiceReviewsStatus.ready => state.reviews.isEmpty
                ? ServiceSectionMessage(
                    icon: Icons.rate_review_outlined,
                    message: l10n.reviewsEmpty,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final review in state.reviews) ...[
                        _ReviewCard(review: review),
                        const SizedBox(height: 10),
                      ],
                      if (state.hasMore)
                        ServiceLoadMoreButton(
                          isLoading: state.isLoadingMore,
                          onPressed: () =>
                              context.read<ServiceReviewsCubit>().loadMore(),
                        ),
                    ],
                  ),
          },
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary});

  final ServiceReviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = summary.totalReviews;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Text(
                  summary.averageRating.toStringAsFixed(1),
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                ServiceStars(rating: summary.averageRating, size: 18),
                const SizedBox(height: 4),
                Text(
                  l10n.reviewsCount(total),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                children: [
                  for (var stars = 5; stars >= 1; stars--)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 14,
                            child: Text(
                              '$stars',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Color(0xFFFFB300),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: LinearProgressIndicator(
                                value: total == 0
                                    ? 0
                                    : summary.countFor(stars) / total,
                                minHeight: 6,
                                backgroundColor: scheme.surfaceContainerHighest,
                                color: const Color(0xFFFFB300),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${summary.countFor(stars)}',
                              textAlign: TextAlign.end,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortPills extends StatelessWidget {
  const _SortPills({required this.sort});

  final ServiceReviewSort sort;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cubit = context.read<ServiceReviewsCubit>();
    final options = <(ServiceReviewSort, String, IconData)>[
      (ServiceReviewSort.latest, l10n.sortLatest, Icons.schedule_rounded),
      (ServiceReviewSort.highest, l10n.sortHighest, Icons.trending_up_rounded),
      (ServiceReviewSort.lowest, l10n.sortLowest, Icons.trending_down_rounded),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final (value, label, icon) in options) ...[
            if (value != ServiceReviewSort.latest) const SizedBox(width: 8),
            ChoiceChip(
              key: ValueKey('reviews-sort-${value.wire}'),
              avatar: Icon(icon, size: 16),
              label: Text(label),
              selected: sort == value,
              onSelected: (_) => cubit.changeSort(value),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final ServiceReview review;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final name = review.userName ?? l10n.reviewAnonymous;
    final createdAt = review.createdAt;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: scheme.primaryContainer,
                  foregroundImage: review.userAvatar != null
                      ? NetworkImage(review.userAvatar!)
                      : null,
                  onForegroundImageError: review.userAvatar != null
                      ? (_, _) {}
                      : null,
                  child: Text(
                    name.trim().isEmpty
                        ? '?'
                        : name.trim().substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: scheme.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (createdAt != null)
                        Text(
                          DateFormat.yMMMd(locale).format(createdAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                if (review.isMine)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      l10n.reviewMine,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            ServiceStars(rating: review.rating.toDouble(), size: 15),
            if (review.comment != null) ...[
              const SizedBox(height: 6),
              Text(review.comment!, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewsShimmer extends StatelessWidget {
  const _ReviewsShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        ShimmerBox(height: 120, borderRadius: 16),
        SizedBox(height: 10),
        ShimmerBox(height: 90, borderRadius: 16),
        SizedBox(height: 10),
        ShimmerBox(height: 90, borderRadius: 16),
      ],
    );
  }
}