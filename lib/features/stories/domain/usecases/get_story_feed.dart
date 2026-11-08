import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/stories/domain/entities/story_feed.dart';
import 'package:dali_alsham/features/stories/domain/repositories/story_repository.dart';

class StoryFeedParams {
  const StoryFeedParams({
    required this.locale,
    this.page = 1,
    this.perPage = 20,
  });

  final String locale;
  final int page;

  /// How many stories a page carries; the backend caps it, so asking for more
  /// than the cap still returns one page.
  final int perPage;
}

class GetStoryFeed implements UseCase<StoryFeed, StoryFeedParams> {
  const GetStoryFeed(this._repository);

  final StoryRepository _repository;

  @override
  Future<Result<StoryFeed>> call(StoryFeedParams params) => _repository.getFeed(
    locale: params.locale,
    page: params.page,
    perPage: params.perPage,
  );
}
