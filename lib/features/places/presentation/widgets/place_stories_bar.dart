import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import 'category_info.dart';

/// Horizontal "stories" strip ("تستحق التجربة") displaying vertical story cards
/// with a top-left circular brand/place avatar ring.
///
/// The strip of nearby places stands in for the services' own stories while the
/// public listing has none, so the section is never an empty row and a place
/// profile stays reachable.
class PlaceStoriesBar extends StatelessWidget {
  const PlaceStoriesBar({
    super.key,
    required this.places,
    required this.viewedIds,
    required this.onStoryTap,
    this.onMoreTap,
  });

  final List<Place> places;

  /// Ids of already-watched stories; their rings are shown in grey instead of green.
  final Set<String> viewedIds;

  final void Function(Place place, int index) onStoryTap;

  /// Optional callback when tapping "المزيد" in the header.
  final VoidCallback? onMoreTap;

  static const maxStories = 12;
  static const cardWidth = 112.0;
  static const cardHeight = 168.0;

  @override
  Widget build(BuildContext context) {
    if (places.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final stories = places.take(maxStories).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10n.storiesTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onMoreTap,
                behavior: HitTestBehavior.opaque,
                child: Text(
                  Localizations.localeOf(context).languageCode == 'ar'
                      ? 'المزيد'
                      : 'More',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: cardHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
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

  static const _activeRingColor = Color(0xFF00B843);
  static const _viewedRingColor = Color(0xFFBDBDBD);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = place.displayNameFor(
      Localizations.localeOf(context).languageCode,
    );

    const String? coverImageUrl = null;
    const String? logoImageUrl = null;

    return SizedBox(
      width: PlaceStoriesBar.cardWidth,
      height: PlaceStoriesBar.cardHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background cover (category gradient fallback + optional story image)
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: CategoryInfo.gradient(place.category),
                ),
                child: Center(
                  child: Icon(
                    CategoryInfo.icon(place.category),
                    size: 42,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
              ),
              if (coverImageUrl != null && coverImageUrl.isNotEmpty)
                Image.network(
                  coverImageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),

              // Subtle bottom gradient + place name caption
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.55, 1.0],
                    colors: [
                      const Color(0x00000000),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 8,
                right: 8,
                bottom: 10,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),

              // Top-left circular brand/place avatar with green/grey status ring
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  key: ValueKey('story-ring-${place.id}'),
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: viewed ? _viewedRingColor : _activeRingColor,
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1A1A1A),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: logoImageUrl != null && logoImageUrl.isNotEmpty
                        ? Image.network(
                            logoImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) =>
                                _AvatarFallback(place: place),
                          )
                        : _AvatarFallback(place: place),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: CategoryInfo.gradient(place.category),
      ),
      child: Center(
        // The name is already captioned at the foot of the card, so the small
        // circle carries the category instead of repeating it.
        child: Icon(
          CategoryInfo.icon(place.category),
          size: 22,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
