import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_review.dart';
import 'package:dali_alsham/features/service_profile/domain/repositories/service_profile_repository.dart';

class ServiceReviewsParams {
  const ServiceReviewsParams({
    required this.slug,
    required this.locale,
    this.page = 1,
    this.sort = ServiceReviewSort.latest,
    this.authenticated = false,
  });

  final String slug;
  final String locale;
  final int page;
  final ServiceReviewSort sort;
  final bool authenticated;
}

class GetServiceReviews
    implements UseCase<ServiceReviewPage, ServiceReviewsParams> {
  const GetServiceReviews(this._repository);

  final ServiceProfileRepository _repository;

  @override
  Future<Result<ServiceReviewPage>> call(ServiceReviewsParams params) =>
      _repository.getReviews(
        slug: params.slug,
        locale: params.locale,
        page: params.page,
        sort: params.sort,
        authenticated: params.authenticated,
      );
}