import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/stories/domain/repositories/story_repository.dart';

class StoryViewParams {
  const StoryViewParams({required this.storyId, required this.locale});

  final int storyId;
  final String locale;
}

/// Tells the server, for the signed-in reader, that story [StoryViewParams.storyId]
/// was watched. The listing hands the same story to everyone; only this call
/// carries who looked.
class RecordStoryView implements UseCase<String, StoryViewParams> {
  const RecordStoryView(this._repository);

  final StoryRepository _repository;

  @override
  Future<Result<String>> call(StoryViewParams params) => _repository.recordView(
    storyId: params.storyId,
    locale: params.locale,
  );
}
