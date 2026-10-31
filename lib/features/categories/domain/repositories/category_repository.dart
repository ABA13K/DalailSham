import 'package:dali_alsham/core/error/result.dart';

import '../entities/category_page.dart';
import '../entities/explore_category.dart';

abstract interface class CategoryRepository {
  /// Up to [limit] categories in random order.
  Future<Result<List<ExploreCategory>>> getRandomCategories({
    required String locale,
    int limit,
  });

  /// One page of all categories.
  Future<Result<CategoryPage>> getCategories({
    required String locale,
    int page,
  });
}
