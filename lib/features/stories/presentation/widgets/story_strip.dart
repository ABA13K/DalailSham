import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/story.dart';
import '../cubit/story_feed_cubit.dart';
import '../story_labels.dart';
import 'story_avatar.dart';

/// The stories services posted, as the horizontal strip on the home feed. A
/// card wears the story's own picture when it has one; a poll or a clip is
/// announced by the mark on its cover instead.
class StoryStrip extends StatelessWidget {
  const StoryStrip({
    super.key,
    required this.status,
    required this.stories,
    required this.viewedIds,
    required this.onStoryTap,
  });

  final StoryFeedStatus status;

  /// The feed as it was fetched; the newest first.
  final List<Story> stories;

  /// Keys of already-watched stories; their rings are shown in grey instead of
  /// green. Server-side seen state counts too, so a story the listing marks as
  /// read does not need watching again to grey out.
  final Set<String> viewedIds;

  final void Function(int index) onStoryTap;

  static const cardWidth = 112.0;
  static const cardHeight = 168.0;

  @override
  Widget build(BuildContext context) {
    if (status == StoryFeedStatus.initial || status == StoryFeedStatus.loading) {
      return const _StripShimmer();
    }
    if (status != StoryFeedStatus.ready || stories.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
          child: Text(
            l10n.storiesTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
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
              final story = stories[index];
              return _StoryCard(
                story: story,
                viewed: story.isSeen || viewedIds.contains(story.seenKey),
                onTap: () => onStoryTap(index),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    required this.story,
    required this.viewed,
    required this.onTap,
  });

  static const _activeRingColor = Color(0xFF00B843);
  static const _viewedRingColor = Color(0xFFBDBDBD);

  final Story story;
  final bool viewed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final coverUrl = story.imageUrl;

    return SizedBox(
      width: StoryStrip.cardWidth,
      height: StoryStrip.cardHeight,
      child: Material(
        key: ValueKey('story-card-${story.id}'),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.brand, AppTheme.brandDeep],
                  ),
                ),
                child: Center(
                  child: Icon(
                    storyTypeIcon(story.type),
                    size: 42,
                    color: Colors.white.withValues(alpha: 0.28),
                  ),
                ),
              ),
              if (coverUrl != null && coverUrl.isNotEmpty)
                Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const SizedBox.shrink(),
                ),

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
                  storyCaptionFor(story, l10n),
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

              // Top-left avatar inside the ring that says whether it was read.
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  key: ValueKey('story-ring-${story.id}'),
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: viewed ? _viewedRingColor : _activeRingColor,
                  ),
                  child: StoryAvatar(
                    service: story.service,
                    size: 47,
                    fallbackIcon: storyTypeIcon(story.type),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    child: Text(
                      storyTypeName(l10n, story.type),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
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

class _StripShimmer extends StatelessWidget {
  const _StripShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16, 8, 16, 12),
          child: ShimmerBox(width: 120, height: 18, borderRadius: 9),
        ),
        SizedBox(
          height: StoryStrip.cardHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                const ShimmerBox(
                  width: StoryStrip.cardWidth,
                  height: StoryStrip.cardHeight,
                  borderRadius: 20,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
