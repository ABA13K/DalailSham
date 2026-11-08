import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/stories/domain/repositories/story_repository.dart';

class StoryPollVoteParams {
  const StoryPollVoteParams({
    required this.storyId,
    required this.optionId,
    required this.locale,
  });

  final int storyId;
  final int optionId;
  final String locale;
}

/// One signed-in reader's answer to the poll of a story. The story is addressed
/// by its own id, not by the poll's, and the option by the id the listing gave.
class VoteStoryPoll implements UseCase<String, StoryPollVoteParams> {
  const VoteStoryPoll(this._repository);

  final StoryRepository _repository;

  @override
  Future<Result<String>> call(StoryPollVoteParams params) =>
      _repository.votePoll(
        storyId: params.storyId,
        optionId: params.optionId,
        locale: params.locale,
      );
}
