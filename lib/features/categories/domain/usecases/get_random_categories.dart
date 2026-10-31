import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/categories/domain/repositories/category_repository.dart';

class RandomCategoriesParams {
  const RandomCategoriesParams({required this.locale, this.limit = 8});

  final String locale;
  final int limit;
}

class GetRandomCategories
    implements UseCase<List<ExploreCategory>, RandomCategoriesParams> {
  const GetRandomCategories(this._repository);

  final CategoryRepository _repository;

  @override
  Future<Result<List<ExploreCategory>>> call(RandomCategoriesParams params) =>
      _repository.getRandomCategories(
        locale: params.locale,
        limit: params.limit,
      );
}
