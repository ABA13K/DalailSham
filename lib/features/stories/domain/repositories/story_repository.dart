import 'package:dali_alsham/core/error/result.dart';

import '../entities/story_feed.dart';

abstract interface class StoryRepository {
  /// One page of the public stories, in [locale].
  Future<Result<StoryFeed>> getFeed({
    required String locale,
    required int page,
    required int perPage,
  });

  /// One page of every story service [serviceId] posted, in [locale].
  Future<Result<StoryFeed>> getServiceFeed({
    required int serviceId,
    required String locale,
    required int page,
    required int perPage,
  });

  /// Tells the server this signed-in reader watched story [storyId]. The
  /// sentence the endpoint wrote comes back, and nothing else.
  Future<Result<String>> recordView({
    required int storyId,
    required String locale,
  });

  /// Sends [optionId] as this reader's answer to the poll of story [storyId].
  Future<Result<String>> votePoll({
    required int storyId,
    required int optionId,
    required String locale,
  });
}
