import '../../../../core/network/remote_image.dart';
import '../../domain/entities/story.dart';

/// JSON/DTO representation of [Story].
class StoryModel extends Story {
  const StoryModel({
    required super.id,
    required super.type,
    super.caption,
    super.imageUrl,
    super.videoUrl,
    super.isSeen,
    super.hoursLeft,
    super.service,
    super.poll,
  });

  /// A row the app cannot draw — no id, or a `type` it does not know how to
  /// show — is left out of the feed instead of failing the whole page.
  static StoryModel? tryFromJson(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final id = json['id'];
    final type = StoryType.fromWire(json['type']);
    if (id is! num || type == null) return null;

    return StoryModel(
      id: id.toInt(),
      type: type,
      caption: _text(json['caption']),
      imageUrl: normalizeRemoteImageUrl(json['image']),
      videoUrl: normalizeRemoteImageUrl(json['video']),
      isSeen: _flag(json['is_seen']),
      hoursLeft: (json['hours_left'] as num?)?.toInt(),
      service: _service(json['service']),
      poll: type == StoryType.poll ? _poll(json['poll']) : null,
    );
  }

  static StoryService? _service(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final id = value['id'];
    final name = value['name'];
    if (id is! num || name is! String || name.trim().isEmpty) return null;

    return StoryService(
      id: id.toInt(),
      name: name.trim(),
      slug: _text(value['slug']),
      imageUrl: normalizeRemoteImageUrl(value['image']),
    );
  }

  static StoryPoll? _poll(Object? value) {
    if (value is! Map<String, dynamic>) return null;
    final id = value['id'];
    final question = _text(value['question']);
    if (id is! num || question == null) return null;

    final rawOptions = value['options'];
    final options = [
      if (rawOptions is List)
        for (final option in rawOptions)
          if (option case final Map<String, dynamic> row)
            if (row['id'] case final num optionId)
              StoryPollOption(
                id: optionId.toInt(),
                text: _text(row['option']) ?? '',
                votesCount: (row['votes_count'] as num?)?.toInt() ?? 0,
              ),
    ];
    // A question nobody can answer is not a poll.
    if (options.isEmpty) return null;

    final totalVotes = (value['total_votes'] as num?)?.toInt() ?? 0;
    return StoryPoll(
      id: id.toInt(),
      question: question,
      totalVotes: totalVotes > 0
          ? totalVotes
          : options.fold(0, (sum, option) => sum + option.votesCount),
      options: options,
      myVoteOptionId: (value['my_vote'] as num?)?.toInt(),
    );
  }

  /// The listing answers `true`/`false` here and `1`/`0` elsewhere.
  static bool _flag(Object? value) =>
      value == true || value == 1 || value == '1';

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
