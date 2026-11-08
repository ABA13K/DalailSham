import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_product.dart';
import 'package:dali_alsham/features/service_profile/domain/repositories/service_profile_repository.dart';

class ServiceProductsParams {
  const ServiceProductsParams({
    required this.slug,
    required this.locale,
    this.page = 1,
    this.categorySlug,
  });

  final String slug;
  final String locale;
  final int page;

  /// Null reads the whole menu; a slug narrows it to one category.
  final String? categorySlug;
}

class GetServiceProducts
    implements UseCase<ServiceProductPage, ServiceProductsParams> {
  const GetServiceProducts(this._repository);

  final ServiceProfileRepository _repository;

  @override
  Future<Result<ServiceProductPage>> call(ServiceProductsParams params) =>
      _repository.getProducts(
        slug: params.slug,
        locale: params.locale,
        page: params.page,
        categorySlug: params.categorySlug,
      );
}