import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/categories/domain/entities/category_page.dart';
import 'package:dali_alsham/features/categories/domain/repositories/category_repository.dart';

class CategoryPageParams {
  const CategoryPageParams({required this.locale, this.page = 1});

  final String locale;
  final int page;
}

class GetCategoryPage implements UseCase<CategoryPage, CategoryPageParams> {
  const GetCategoryPage(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<CategoryPage>> call(CategoryPageParams params) =>
      _repository.getCategories(locale: params.locale, page: params.page);
}
