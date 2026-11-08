import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../core/settings/presentation/locale_cubit.dart';
import '../../../../core/settings/presentation/token_cubit.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../places/presentation/cubit/stories_seen_cubit.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/record_story_view.dart';
import '../../domain/usecases/vote_story_poll.dart';
import '../story_labels.dart';
import '../widgets/story_avatar.dart';
import 'service_story_list_page.dart';

/// Payload for opening the service-story viewer at a specific story.
class ServiceStoriesArgs {
  const ServiceStoriesArgs({required this.stories, this.initialIndex = 0});

  final List<Story> stories;
  final int initialIndex;
}

/// Full-screen, auto-advancing viewer for the stories services posted.
class ServiceStoriesPage extends StatefulWidget {
  const ServiceStoriesPage({
    super.key,
    required this.stories,
    this.initialIndex = 0,
  });

  final List<Story> stories;
  final int initialIndex;

  @override
  State<ServiceStoriesPage> createState() => _ServiceStoriesPageState();
}

class _ServiceStoriesPageState extends State<ServiceStoriesPage>
    with SingleTickerProviderStateMixin {
  static const _storyDuration = Duration(seconds: 5);
  static const _slideDuration = Duration(milliseconds: 260);

  late final PageController _pageController;
  late final AnimationController _progress;

  /// The clip of the story on screen, held by the page so leaving the slide
  /// always releases the decoder.
  VideoPlayerController? _video;
  late int _index;

  /// Whether the platform still answers for clips. The one that refuses ends
  /// the asking, since every later clip would refuse the same way; each slide
  /// has a poster of its own and five seconds to run while it is not there.
  bool _clipsAnswer = true;

  /// Counts the slides the reader has been moved through. A clip that opens
  /// after the slide it was asked for is gone belongs to nobody.
  int _clipTicket = 0;

  /// The stories as this viewer shows them. A poll the reader answered is
  /// redrawn here, before the listing is asked again.
  late final List<Story> _stories;

  /// Stories this visit already told the server about.
  final Set<int> _viewsSent = {};

  /// The story whose answer is on its way, so no second one leaves.
  int? _votingStoryId;

  @override
  void initState() {
    super.initState();
    _stories = List.of(widget.stories);
    _index = _stories.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _stories.length - 1);
    _pageController = PageController(initialPage: _index);
    _progress = AnimationController(
      vsync: this,
      duration: _storyDuration,
    )..addStatusListener(_onProgressStatus);
    if (widget.stories.isNotEmpty) _show(_index);
  }

  @override
  void dispose() {
    _progress.dispose();
    _pageController.dispose();
    // The page is gone either way, so the clip is released without waiting.
    _releaseVideo();
    super.dispose();
  }

  Future<void> _show(int index) async {
    setState(() => _index = index);
    final story = _stories[index];
    context.read<StoriesSeenCubit>().markViewed(story.seenKey);
    _recordView(story);
    _releaseVideo();
    final ticket = _clipTicket;

    _progress.duration = _storyDuration;
    final url = story.videoUrl;
    if (story.type == StoryType.video && url != null && _clipsAnswer) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      try {
        await controller.initialize();
        if (!mounted || ticket != _clipTicket) {
          _discard(controller);
          return;
        }
        // The bar keeps time with the clip instead of a fixed five seconds.
        final clip = controller.value.duration;
        _progress.duration = clip > Duration.zero ? clip : _storyDuration;
        // The slide was drawn from the poster while the clip opened, so the
        // clip only reaches the screen once the page is built again.
        setState(() => _video = controller);
        await controller.play();
      } catch (_) {
        // No network, no codec or no plugin behind this build: the slide runs
        // its own five seconds as a poster, like any other story.
        _clipsAnswer = false;
        _progress.duration = _storyDuration;
        _discard(controller);
      }
      if (!mounted || ticket != _clipTicket) return;
    }

    _progress
      ..reset()
      ..forward();
  }

  /// Hands the clip of the slide being left back to the plugin without waiting
  /// for it: when the clip never opened, that handback is a call that never
  /// returns, and a story the reader is watching cannot wait on it.
  void _releaseVideo() {
    _clipTicket++;
    final controller = _video;
    _video = null;
    if (controller != null) _discard(controller);
  }

  void _discard(VideoPlayerController controller) {
    // A clip that never opened has nothing to hand back, and asking for it
    // would throw over a story the reader can still see.
    controller.dispose().catchError((Object _) {});
  }

  /// Says of this story that the signed-in reader watched it. A reader who is
  /// not signed in has nothing to say, one story is said once a visit, and the
  /// sentence the endpoint answers with is not something the reader asked
  /// about — the ring by the card already greyed itself locally.
  void _recordView(Story story) {
    if (_viewsSent.contains(story.id)) return;
    if (_signedIn == false) return;
    _viewsSent.add(story.id);
    getIt<RecordStoryView>()(
      StoryViewParams(storyId: story.id, locale: _locale),
    );
  }

  /// The reader's answer to a poll. Once the server takes it, the option gains
  /// its vote on this screen; a refusal leaves the tally where it stood and
  /// says so.
  Future<void> _vote(Story story, int optionId) async {
    if (_votingStoryId != null) return;
    setState(() => _votingStoryId = story.id);

    final outcome = await getIt<VoteStoryPoll>()(
      StoryPollVoteParams(
        storyId: story.id,
        optionId: optionId,
        locale: _locale,
      ),
    );
    if (!mounted) return;

    final l10n = AppLocalizations.of(context);
    outcome.fold((failure) {
      setState(() => _votingStoryId = null);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(l10n.storyVoteFailed),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }, (_) {
      final at = _stories.indexWhere((row) => row.id == story.id);
      setState(() {
        _votingStoryId = null;
        if (at >= 0) _stories[at] = _stories[at].withVote(optionId);
      });
    });
  }

  bool get _signedIn => context.read<TokenCubit>().state != null;

  String get _locale => context.read<LocaleCubit>().state.languageCode;

  /// The whole set this story came from, which is what the strip mixed
  /// together and the feed cut off after the newest page.
  void _openServiceStories(Story story) {
    final service = story.service;
    if (service == null) return;

    context.push(
      '/service-stories/list',
      extra: ServiceStoryListArgs(
        serviceId: service.id,
        serviceName: service.name,
      ),
    );
  }

  void _onProgressStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) _advance();
  }

  void _advance() {
    if (!mounted) return;
    if (_index >= _stories.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    _progress.stop();
    _pageController.nextPage(
      duration: _slideDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _rewind() {
    if (!mounted) return;
    if (_index == 0) {
      _progress
        ..reset()
        ..forward();
      return;
    }
    _progress.stop();
    _pageController.previousPage(
      duration: _slideDuration,
      curve: Curves.easeOutCubic,
    );
  }

  void _onPageChanged(int index) {
    if (index == _index) return;
    _show(index);
  }

  void _pause() {
    _progress.stop();
    _video?.pause();
  }

  void _resume() {
    if (!_progress.isAnimating) _progress.forward();
    _video?.play();
  }

  void _handleTap(TapUpDetails details) {
    final width = MediaQuery.sizeOf(context).width;
    if (details.localPosition.dx < width * 0.35) {
      _rewind();
    } else {
      _advance();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stories.isEmpty) {
      return const Scaffold(backgroundColor: Colors.black);
    }
    final signedIn = _signedIn;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                final story = _stories[index];
                final isCurrent = index == _index;
                final poll = story.poll;
                return _StorySlide(
                  story: story,
                  video: isCurrent ? _video : null,
                  canVote:
                      isCurrent &&
                      signedIn &&
                      poll != null &&
                      poll.myVoteOptionId == null,
                  voteSending: isCurrent && _votingStoryId == story.id,
                  onVote: (optionId) => _vote(story, optionId),
                  onTapUp: _handleTap,
                  onLongPressStart: (_) => _pause(),
                  onLongPressEnd: (_) => _resume(),
                );
              },
            ),
            PositionedDirectional(
              top: 0,
              start: 0,
              end: 0,
              child: _StoryChrome(
                story: _stories[_index],
                index: _index,
                count: _stories.length,
                progress: _progress,
                onClose: () => Navigator.of(context).maybePop(),
                onOpenService: () => _openServiceStories(_stories[_index]),
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
    required this.story,
    required this.index,
    required this.count,
    required this.progress,
    required this.onClose,
    required this.onOpenService,
  });

  final Story story;
  final int index;
  final int count;
  final Animation<double> progress;
  final VoidCallback onClose;

  /// Opening what the service posted is only offered when the story names one.
  final VoidCallback? onOpenService;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hoursLeft = story.hoursLeft;
    final service = story.service;

    final identity = Row(
      children: [
        StoryAvatar(
          service: service,
          size: 36,
          fallbackIcon: storyTypeIcon(story.type),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                storyCaptionFor(story, l10n),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                // A story that names its service is dated by the hours it has
                // left; one that does not just says now.
                hoursLeft == null
                    ? l10n.storiesNow
                    : l10n.storyExpiresIn(hoursLeft),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
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
                    Expanded(
                      child: service == null
                          ? identity
                          : Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                key: ValueKey('story-open-service-${service.id}'),
                                onTap: onOpenService,
                                // The row reads as the service's name, so say
                                // what tapping it opens.
                                child: Tooltip(
                                  message: l10n.serviceStoriesAll,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                      vertical: 2,
                                    ),
                                    child: identity,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    if (service != null)
                      TextButton(
                        key: ValueKey('story-open-service-all-${service.id}'),
                        onPressed: onOpenService,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(l10n.seeAll),
                      ),
                    IconButton(
                      onPressed: onClose,
                      tooltip: l10n.storiesClose,
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
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
    required this.story,
    required this.video,
    required this.canVote,
    required this.voteSending,
    required this.onVote,
    required this.onTapUp,
    required this.onLongPressStart,
    required this.onLongPressEnd,
  });

  final Story story;
  final VideoPlayerController? video;

  /// Whether this reader may answer the poll now: signed in, on this slide and
  /// with no answer of theirs on it yet.
  final bool canVote;

  /// Whether this slide's answer is still on its way to the server.
  final bool voteSending;
  final ValueChanged<int> onVote;
  final GestureTapUpCallback onTapUp;
  final GestureLongPressStartCallback onLongPressStart;
  final GestureLongPressEndCallback onLongPressEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final coverUrl = story.imageUrl;

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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.brand, AppTheme.brandDeep],
              ),
            ),
            child: coverUrl == null
                ? Center(
                    child: Icon(
                      storyTypeIcon(story.type),
                      size: 160,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  )
                : null,
          ),
          if (coverUrl != null)
            Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Center(
                child: Icon(
                  Icons.broken_image_rounded,
                  size: 120,
                  color: Colors.white.withValues(alpha: 0.35),
                ),
              ),
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : const SizedBox.shrink(),
            ),
          if (video != null && video!.value.isInitialized)
            Center(
              child: AspectRatio(
                aspectRatio: video!.value.aspectRatio,
                child: VideoPlayer(video!),
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
                      if (story.poll case final poll?) ...[
                        _PollCard(
                          poll: poll,
                          canVote: canVote,
                          sending: voteSending,
                          onVote: onVote,
                        ),
                        const SizedBox(height: 18),
                      ],
                      _TypePill(story: story),
                      const SizedBox(height: 12),
                      if (story.caption != null)
                        Text(
                          story.caption!,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
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

class _TypePill extends StatelessWidget {
  const _TypePill({required this.story});

  final Story story;

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
          Icon(storyTypeIcon(story.type), size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            storyTypeName(l10n, story.type),
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

/// The poll as the listing hands it over: the question, every answer on offer
/// and the share of the votes each took. A signed-in reader picks one; the
/// tally is what everybody else sees.
class _PollCard extends StatelessWidget {
  const _PollCard({
    required this.poll,
    required this.canVote,
    required this.sending,
    required this.onVote,
  });

  final StoryPoll poll;
  final bool canVote;
  final bool sending;
  final ValueChanged<int> onVote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // One answer at a time, and none while the last one is still on its way.
    final tappable = canVote && !sending;

    return Container(
      key: ValueKey('story-poll-${poll.id}'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            poll.question,
            style: theme.textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          if (canVote)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  if (sending)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(
                      Icons.how_to_vote_rounded,
                      size: 15,
                      color: Colors.white70,
                    ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.storyVoteHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          for (final option in poll.options) ...[
            _PollOptionRow(
              option: option,
              poll: poll,
              showTally: !canVote,
              isMyVote: option.id == poll.myVoteOptionId,
              onTap: tappable ? () => onVote(option.id) : null,
            ),
            const SizedBox(height: 8),
          ],
          if (poll.totalVotes > 0)
            Row(
              children: [
                const Icon(Icons.groups_rounded, size: 15, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  '${poll.totalVotes}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            )
          else
            Text(
              l10n.storyNoVotes,
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
        ],
      ),
    );
  }
}

class _PollOptionRow extends StatelessWidget {
  const _PollOptionRow({
    required this.option,
    required this.poll,
    required this.showTally,
    required this.isMyVote,
    required this.onTap,
  });

  final StoryPollOption option;
  final StoryPoll poll;

  /// Whether the row carries its share of the votes. A reader who still has an
  /// answer to give sees the choices, not the counts.
  final bool showTally;

  /// Whether this reader's own answer is the one on this row.
  final bool isMyVote;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final share = poll.shareOf(option);

    return ClipRRect(
      key: ValueKey('story-poll-option-${option.id}'),
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Semantics(
          button: onTap != null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(
                color: isMyVote
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.24),
              ),
            ),
            child: Stack(
              children: [
                if (showTally)
                  Positioned.fill(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FractionallySizedBox(
                        widthFactor: share,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      if (isMyVote) ...[
                        const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                      ] else if (!showTally) ...[
                        const Icon(
                          Icons.radio_button_unchecked_rounded,
                          size: 16,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          option.text,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (showTally) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${(share * 100).round()}%',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
