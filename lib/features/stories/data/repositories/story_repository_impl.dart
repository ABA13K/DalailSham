import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/story_feed.dart';
import '../../domain/repositories/story_repository.dart';
import '../datasources/story_remote_datasource.dart';

/// Hands the cubit the public story feed as a [Result], failure included.
class StoryRepositoryImpl implements StoryRepository {
  const StoryRepositoryImpl(this._remoteDataSource);

  final StoryRemoteDataSource _remoteDataSource;

  @override
  Future<Result<StoryFeed>> getFeed({
    required String locale,
    required int page,
    required int perPage,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchStories(
          locale: locale,
          page: page,
          perPage: perPage,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<StoryFeed>> getServiceFeed({
    required int serviceId,
    required String locale,
    required int page,
    required int perPage,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchServiceStories(
          serviceId: serviceId,
          locale: locale,
          page: page,
          perPage: perPage,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<String>> recordView({
    required int storyId,
    required String locale,
  }) => _said(
    () => _remoteDataSource.recordView(storyId: storyId, locale: locale),
  );

  @override
  Future<Result<String>> votePoll({
    required int storyId,
    required int optionId,
    required String locale,
  }) => _said(
    () => _remoteDataSource.votePoll(
      storyId: storyId,
      optionId: optionId,
      locale: locale,
    ),
  );

  /// The two signed-in calls hand back nothing but the sentence they were
  /// answered with, so the exception is the only failure they can carry.
  Future<Result<String>> _said(Future<String> Function() say) async {
    try {
      return Success(await say());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
