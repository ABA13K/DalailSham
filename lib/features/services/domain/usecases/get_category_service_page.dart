import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/services/domain/entities/category_service_page.dart';
import 'package:dali_alsham/features/services/domain/repositories/category_service_repository.dart';

class CategoryServicePageParams {
  const CategoryServicePageParams({
    required this.categoryId,
    required this.locale,
    this.page = 1,
    this.userLat,
    this.userLng,
  });

  final int categoryId;
  final String locale;
  final int page;
  final double? userLat;
  final double? userLng;
}

class GetCategoryServicePage
    implements UseCase<CategoryServicePage, CategoryServicePageParams> {
  const GetCategoryServicePage(this._repository);

  final CategoryServiceRepository _repository;

  @override
  Future<Result<CategoryServicePage>> call(CategoryServicePageParams params) =>
      _repository.getServices(
        categoryId: params.categoryId,
        locale: params.locale,
        page: params.page,
        userLat: params.userLat,
        userLng: params.userLng,
      );
}
