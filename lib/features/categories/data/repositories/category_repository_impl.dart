import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:dali_alsham/features/categories/domain/entities/category_page.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  const CategoryRepositoryImpl(this._remoteDataSource);

  final CategoryRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<ExploreCategory>>> getRandomCategories({
    required String locale,
    int limit = 8,
  }) async {
    try {
      final random = await _remoteDataSource.fetchRandomCategories(
        locale: locale,
      );
      final picked = random.take(limit).toList();
      if (picked.length >= limit) return Success(picked);

      // The random endpoint returns a single category; fill the rail from the
      // full list so it is not left with one card.
      try {
        final page = await _remoteDataSource.fetchCategories(
          locale: locale,
          page: 1,
        );
        final seen = {for (final category in picked) category.id};
        final extra =
            page.categories
                .where((category) => !seen.contains(category.id))
                .toList()
              ..shuffle();
        return Success([...picked, ...extra].take(limit).toList());
      } catch (_) {
        return Success(picked);
      }
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<CategoryPage>> getCategories({
    required String locale,
    int page = 1,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchCategories(locale: locale, page: page),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
