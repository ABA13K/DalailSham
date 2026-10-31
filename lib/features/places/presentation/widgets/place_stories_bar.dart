import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import 'category_info.dart';

/// Horizontal "stories" strip highlighting the nearest places.
class PlaceStoriesBar extends StatelessWidget {
  const PlaceStoriesBar({
    super.key,
    required this.places,
    required this.viewedIds,
    required this.onStoryTap,
  });

  final List<Place> places;

  /// Ids of already-watched stories; their rings are shown in grey.
  final Set<String> viewedIds;

  final void Function(Place place, int index) onStoryTap;

  static const maxStories = 12;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stories = places.take(maxStories).toList();
    final labelStyle = theme.textTheme.labelSmall;
    final labelHeight =
        MediaQuery.textScalerOf(context).scale(labelStyle?.fontSize ?? 11) *
        (labelStyle?.height ?? 1.45);
    final itemHeight = 66 + 6 + labelHeight + 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 10),
          child: Text(
            l10n.storiesTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: itemHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final place = stories[index];
              return _StoryItem(
                place: place,
                viewed: viewedIds.contains(place.id),
                onTap: () => onStoryTap(place, index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({
    required this.place,
    required this.viewed,
    required this.onTap,
  });

  final Place place;
  final bool viewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = place.displayNameFor(
      Localizations.localeOf(context).languageCode,
    );

    final ring = viewed
        ? const LinearGradient(
            colors: [Color(0xFFBDBDBD), Color(0xFF8A8A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : SweepGradient(
            startAngle: -1.2,
            endAngle: 4.4,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.tertiary,
              theme.colorScheme.primary,
            ],
          );

    return SizedBox(
      width: 80,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              key: ValueKey('story-ring-${place.id}'),
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: ring),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: CategoryInfo.gradient(place.category),
                  ),
                  child: Center(
                    child: Icon(
                      CategoryInfo.icon(place.category),
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }
}
