import 'story.dart';

/// One page of the public stories listing.
class StoryFeed {
  const StoryFeed({
    required this.stories,
    required this.hasMore,
    this.nextPage,
  });

  final List<Story> stories;
  final bool hasMore;
  final int? nextPage;
}
