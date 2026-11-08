import 'package:equatable/equatable.dart';

/// What a published story shows: a picture, a clip or a poll.
enum StoryType {
  image('image'),
  video('video'),
  poll('poll');

  const StoryType(this.wire);

  final String wire;

  static StoryType? fromWire(Object? value) {
    if (value is! String) return null;
    final wire = value.trim().toLowerCase();
    for (final type in values) {
      if (type.wire == wire) return type;
    }
    return null;
  }
}

/// The service a story was posted from, which is what the viewer offers to
/// open next.
class StoryService extends Equatable {
  const StoryService({
    required this.id,
    required this.name,
    this.slug,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? slug;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, slug, imageUrl];
}

/// One answer the vendor offered, and how many times it was picked.
class StoryPollOption extends Equatable {
  const StoryPollOption({
    required this.id,
    required this.text,
    required this.votesCount,
  });

  final int id;
  final String text;
  final int votesCount;

  @override
  List<Object?> get props => [id, text, votesCount];
}

class StoryPoll extends Equatable {
  const StoryPoll({
    required this.id,
    required this.question,
    required this.totalVotes,
    required this.options,
    this.myVoteOptionId,
  });

  final int id;
  final String question;
  final int totalVotes;
  final List<StoryPollOption> options;

  /// The option this reader picked, when the answer came back with one.
  final int? myVoteOptionId;

  /// The share of the votes an option took, used to draw its bar. An option
  /// nobody picked still gets a sliver so the row is not read as missing.
  double shareOf(StoryPollOption option) => totalVotes <= 0
      ? 0
      : (option.votesCount / totalVotes).clamp(0.0, 1.0).toDouble();

  /// The poll once this reader's answer is on record: [optionId] gained the
  /// vote, the total moved with it and the answer is theirs, so no second one
  /// follows. An option of another poll, or a reader who already answered,
  /// leaves the tally where it stands.
  StoryPoll withVote(int optionId) {
    if (myVoteOptionId != null) return this;
    if (!options.any((option) => option.id == optionId)) return this;

    return StoryPoll(
      id: id,
      question: question,
      totalVotes: totalVotes + 1,
      options: [
        for (final option in options)
          if (option.id == optionId)
            StoryPollOption(
              id: option.id,
              text: option.text,
              votesCount: option.votesCount + 1,
            )
          else
            option,
      ],
      myVoteOptionId: optionId,
    );
  }

  @override
  List<Object?> get props => [id, question, totalVotes, options, myVoteOptionId];
}

/// A story the public listing hands to every reader.
class Story extends Equatable {
  const Story({
    required this.id,
    required this.type,
    this.caption,
    this.imageUrl,
    this.videoUrl,
    this.isSeen = false,
    this.hoursLeft,
    this.service,
    this.poll,
  });

  final int id;
  final StoryType type;
  final String? caption;
  final String? imageUrl;
  final String? videoUrl;

  /// Whether this reader already watched it, as the server last knew.
  final bool isSeen;

  /// Hours before the story drops off the feed.
  final int? hoursLeft;
  final StoryService? service;

  /// Filled for [StoryType.poll] only.
  final StoryPoll? poll;

  /// Key this story's watched state is stored under. The list of watched
  /// stories also holds the place stories' ids, so the two are kept apart.
  String get seenKey => 'service-story-$id';

  /// The story with [optionId] answered on its poll, which is how the slide
  /// redraws itself once the server took the reader's answer.
  Story withVote(int optionId) {
    final poll = this.poll;
    if (poll == null) return this;

    return Story(
      id: id,
      type: type,
      caption: caption,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      isSeen: isSeen,
      hoursLeft: hoursLeft,
      service: service,
      poll: poll.withVote(optionId),
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    caption,
    imageUrl,
    videoUrl,
    isSeen,
    hoursLeft,
    service,
    poll,
  ];
}
