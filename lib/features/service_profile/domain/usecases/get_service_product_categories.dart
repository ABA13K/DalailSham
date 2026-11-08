import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_product.dart';
import 'package:dali_alsham/features/service_profile/domain/repositories/service_profile_repository.dart';

class ServiceProductCategoriesParams {
  const ServiceProductCategoriesParams({
    required this.slug,
    required this.locale,
  });

  final String slug;
  final String locale;
}

class GetServiceProductCategories
    implements
        UseCase<List<ServiceProductCategory>, ServiceProductCategoriesParams> {
  const GetServiceProductCategories(this._repository);

  final ServiceProfileRepository _repository;

  @override
  Future<Result<List<ServiceProductCategory>>> call(
    ServiceProductCategoriesParams params,
  ) => _repository.getProductCategories(
    slug: params.slug,
    locale: params.locale,
  );
}