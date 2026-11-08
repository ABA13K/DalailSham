import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/distance_formatter.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import '../cubit/stories_seen_cubit.dart';
import '../widgets/category_info.dart';

/// Payload for opening the story viewer at a specific place.
class StoriesArgs {
  const StoriesArgs({required this.places, this.initialIndex = 0});

  final List<Place> places;
  final int initialIndex;
}

/// Full-screen, auto-advancing story viewer for nearby places.
class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key, required this.places, this.initialIndex = 0});

  final List<Place> places;
  final int initialIndex;

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage>
    with SingleTickerProviderStateMixin {
  static const _storyDuration = Duration(seconds: 5);
  static const _slideDuration = Duration(milliseconds: 260);

  late final PageController _pageController;
  late final AnimationController _progressController;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.places.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, widget.places.length - 1);
    _pageController = PageController(initialPage: _index);
    _progressController = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )..addStatusListener(_onProgressStatus);
    if (widget.places.isNotEmpty) {
      _markViewed(widget.places[_index]);
      _progressController.forward();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _advance();
  }

  void _advance() {
    if (!mounted) return;
    if (_index >= widget.places.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    _progressController.stop();
    _pageController.nextPage(
      duration: _slideDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _rewind() {
    if (!mounted) return;
    if (_index == 0) {
      _progressController
        ..reset()
        ..forward();
      return;
    }
    _progressController.stop();
    _pageController.previousPage(
      duration: _slideDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    _markViewed(widget.places[index]);
    setState(() => _index = index);
    _progressController
      ..reset()
      ..forward();
  }

  void _markViewed(Place place) {
    context.read<StoriesSeenCubit>().markViewed(place.id);
  }

  void _pause() => _progressController.stop();

  void _resume() {
    if (!_progressController.isAnimating) _progressController.forward();
  }

  void _handleTap(TapUpDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    if (details.localPosition.dx < width * 0.35) {
      _rewind();
    } else {
      _advance();
    }
  }

  void _openPlace(Place place) {
    context.pushReplacement('/place', extra: place);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.places.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: widget.places.length,
              itemBuilder: (context, index) {
                final place = widget.places[index];
                return _StorySlide(
                  place: place,
                  onTapUp: _handleTap,
                  onLongPressStart: (_) => _pause(),
                  onLongPressEnd: (_) => _resume(),
                  onOpenPlace: () => _openPlace(place),
                );
              },
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: _StoryChrome(
                place: widget.places[_index],
                index: _index,
                count: widget.places.length,
                progress: _progressController,
                onClose: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryChrome extends StatelessWidget {
  const _StoryChrome({
    required this.place,
    required this.index,
    required this.count,
    required this.progress,
    required this.onClose,
  });

  final Place place;
  final int index;
  final int count;
  final Animation<double> progress;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final name = place.displayNameFor(
      Localizations.localeOf(context).languageCode,
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x99000000), Color(0x00000000)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: CenteredContent(
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: progress,
                  builder: (context, _) => Row(
                    children: [
                      for (var i = 0; i < count; i++) ...[
                        if (i > 0) const SizedBox(width: 4),
                        Expanded(
                          child: _ProgressSegment(
                            value: i < index
                                ? 1
                                : i > index
                                ? 0
                                : progress.value,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.22),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.45),
                        ),
                      ),
                      child: Icon(
                        CategoryInfo.icon(place.category),
                        size: 18,
                        color: Colors.white,
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
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${CategoryInfo.label(l10n, place.category)}'
                            ' · ${l10n.storiesNow}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: onClose,
                      tooltip: l10n.storiesClose,
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  const _ProgressSegment({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 3,
        backgroundColor: Colors.white.withValues(alpha: 0.3),
        color: Colors.white,
      ),
    );
  }
}

class _StorySlide extends StatelessWidget {
  const _StorySlide({
    required this.place,
    required this.onTapUp,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onOpenPlace,
  });

  final Place place;
  final GestureTapUpCallback onTapUp;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressEndCallback onLongPressEnd;
  final VoidCallback onOpenPlace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final name = place.displayNameFor(
      Localizations.localeOf(context).languageCode,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: onTapUp,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: CategoryInfo.gradient(place.category),
            ),
          ),
          PositionedDirectional(
            top: -70,
            end: -70,
            child: _Glow(size: 280, opacity: 0.12),
          ),
          PositionedDirectional(
            bottom: 120,
            start: -90,
            child: _Glow(size: 240, opacity: 0.08),
          ),
          Center(
            child: Icon(
              CategoryInfo.icon(place.category),
              size: 200,
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x00000000), Color(0xCC000000)],
                stops: [0.4, 1],
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: CenteredContent(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 28),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CategoryPill(place: place),
                      const SizedBox(height: 14),
                      Text(
                        name,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.08,
                        ),
                      ),
                      if (place.address != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          place.address!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (place.distanceMeters != null)
                            _InfoChip(
                              icon: Icons.near_me_rounded,
                              label: formatDistance(
                                l10n,
                                place.distanceMeters!,
                              ),
                            ),
                          if (place.openingHours != null)
                            _InfoChip(
                              icon: Icons.schedule_rounded,
                              label: place.openingHours!,
                              ltrText: true,
                            ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      FilledButton.icon(
                        key: const ValueKey('story-open-place'),
                        onPressed: onOpenPlace,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: Text(l10n.viewPlace),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CategoryInfo.icon(place.category),
            size: 15,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Text(
            CategoryInfo.label(l10n, place.category),
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.ltrText = false,
  });

  final IconData icon;
  final String label;

  /// Keeps numeric ranges (opening hours) readable inside RTL layouts.
  final bool ltrText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: ltrText ? TextDirection.ltr : null,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
