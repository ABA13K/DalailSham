import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/stories/domain/entities/story_feed.dart';
import 'package:dali_alsham/features/stories/domain/repositories/story_repository.dart';

class ServiceStoryFeedParams {
  const ServiceStoryFeedParams({
    required this.serviceId,
    required this.locale,
    this.page = 1,
    this.perPage = 20,
  });

  /// The service whose stories are asked for.
  final int serviceId;
  final String locale;
  final int page;
  final int perPage;
}

/// Every story one service posted, page by page. The public feed mixes the
/// services together and drops the older ones; this listing is what a service
/// has on its own.
class GetServiceStoryFeed implements UseCase<StoryFeed, ServiceStoryFeedParams> {
  const GetServiceStoryFeed(this._repository);

  final StoryRepository _repository;

  @override
  Future<Result<StoryFeed>> call(ServiceStoryFeedParams params) =>
      _repository.getServiceFeed(
        serviceId: params.serviceId,
        locale: params.locale,
        page: params.page,
        perPage: params.perPage,
      );
}
