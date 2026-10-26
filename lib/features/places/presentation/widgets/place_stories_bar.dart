import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_category.dart';
import 'category_info.dart';

/// Horizontal "stories" strip highlighting the nearest places.
class PlaceStoriesBar extends StatelessWidget {
  const PlaceStoriesBar({
    super.key,
    required this.places,
    required this.onPlaceTap,
  });

  final List<Place> places;
  final ValueChanged<Place> onPlaceTap;

  static const _maxStories = 12;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stories = places.take(_maxStories);

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
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final place = stories.elementAt(index);
              return _StoryItem(place: place, onTap: () => onPlaceTap(place));
            },
          ),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _StoryItem extends StatelessWidget {
  const _StoryItem({required this.place, required this.onTap});

  final Place place;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = place.displayNameFor(
      Localizations.localeOf(context).languageCode,
    );

    return SizedBox(
      width: 80,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  startAngle: -1.2,
                  endAngle: 4.4,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.tertiary,
                    theme.colorScheme.primary,
                  ],
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: _gradientFor(place.category),
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

  static LinearGradient _gradientFor(PlaceCategory category) {
    final colors = switch (category) {
      PlaceCategory.restaurant => [
        const Color(0xFFFF7043),
        const Color(0xFFD84315),
      ],
      PlaceCategory.cafe => [const Color(0xFFA1887F), const Color(0xFF5D4037)],
      PlaceCategory.shopping => [
        const Color(0xFFAB47BC),
        const Color(0xFF6A1B9A),
      ],
      PlaceCategory.health => [
        const Color(0xFF26A69A),
        const Color(0xFF00695C),
      ],
      PlaceCategory.hotel => [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
      PlaceCategory.attraction => [
        const Color(0xFFFFB300),
        const Color(0xFFEF6C00),
      ],
      PlaceCategory.fuel => [const Color(0xFF78909C), const Color(0xFF37474F)],
      PlaceCategory.bank => [const Color(0xFF66BB6A), const Color(0xFF2E7D32)],
      PlaceCategory.other => [const Color(0xFF0D6EFD), const Color(0xFF052A63)],
    };

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
