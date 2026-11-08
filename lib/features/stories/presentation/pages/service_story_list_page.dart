import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/get_service_story_feed.dart';
import '../cubit/service_story_list_cubit.dart';
import '../story_labels.dart';
import 'service_stories_page.dart';

/// Navigation payload for [ServiceStoryListPage].
class ServiceStoryListArgs {
  const ServiceStoryListArgs({required this.serviceId, this.serviceName});

  final int serviceId;

  /// What the reader was watching the list open from; the listing names the
  /// service itself when this is missing.
  final String? serviceName;
}

/// Every story one service posted, newest first, page by page. The home strip
/// mixes the services and drops what is older; this is the whole set.
class ServiceStoryListPage extends StatelessWidget {
  const ServiceStoryListPage({super.key, required this.serviceId, this.serviceName});

  final int serviceId;
  final String? serviceName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    void fetch(ServiceStoryListCubit cubit) =>
        cubit.load(serviceId: serviceId, locale: locale);

    return BlocProvider(
      create: (_) {
        final cubit = ServiceStoryListCubit(getIt<GetServiceStoryFeed>());
        fetch(cubit);
        return cubit;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            serviceName ?? l10n.storiesTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        body: CenteredContent(
          child: BlocBuilder<ServiceStoryListCubit, ServiceStoryListState>(
            builder: (context, state) => switch (state.status) {
              ServiceStoryListStatus.initial ||
              ServiceStoryListStatus.loading => const _StoriesShimmer(),
              ServiceStoryListStatus.failure => _StoriesMessage(
                icon: Icons.cloud_off_rounded,
                message: l10n.placesError,
                action: FilledButton.icon(
                  onPressed: () => fetch(context.read<ServiceStoryListCubit>()),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.retry),
                ),
              ),
              ServiceStoryListStatus.ready => _StoriesBody(state: state),
            },
          ),
        ),
      ),
    );
  }
}

class _StoriesBody extends StatelessWidget {
  const _StoriesBody({required this.state});

  final ServiceStoryListState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (state.stories.isEmpty) {
      return _StoriesMessage(
        icon: Icons.auto_stories_rounded,
        message: l10n.serviceStoriesEmpty,
      );
    }

    final stories = state.stories;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          sliver: SliverList.builder(
            itemCount: stories.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _StoryRow(
                story: stories[index],
                // The viewer runs the whole set from wherever the reader
                // stepped in, so the strip it came from is not needed here.
                onTap: () => context.push(
                  '/service-stories',
                  extra: ServiceStoriesArgs(
                    stories: stories,
                    initialIndex: index,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (state.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: FilledButton.tonal(
                key: const ValueKey('service-stories-more'),
                onPressed: state.isLoadingMore
                    ? null
                    : () => context.read<ServiceStoryListCubit>().loadMore(),
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

/// One story of the service: its cover, what it is and how long it stays.
class _StoryRow extends StatelessWidget {
  const _StoryRow({required this.story, required this.onTap});

  final Story story;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final coverUrl = story.imageUrl;
    final hoursLeft = story.hoursLeft;

    return Material(
      key: ValueKey('service-story-row-${story.id}'),
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 60,
                  height: 82,
                  child: DecoratedBox(
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
                              size: 26,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                          )
                        : Image.network(
                            coverUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              storyTypeIcon(story.type),
                              size: 26,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            loadingBuilder: (context, child, progress) =>
                                progress == null ? child : const SizedBox.shrink(),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.caption ?? storyTypeName(l10n, story.type),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          storyTypeIcon(story.type),
                          size: 14,
                          color: theme.colorScheme.outline,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            storyTypeName(l10n, story.type),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            hoursLeft == null
                                ? l10n.storiesNow
                                : l10n.storyExpiresIn(hoursLeft),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoriesShimmer extends StatelessWidget {
  const _StoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => const ShimmerBox(height: 102, borderRadius: 14),
    );
  }
}

class _StoriesMessage extends StatelessWidget {
  const _StoriesMessage({required this.icon, required this.message, this.action});

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
