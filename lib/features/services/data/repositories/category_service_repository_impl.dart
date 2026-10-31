import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/services/data/datasources/category_service_remote_datasource.dart';
import 'package:dali_alsham/features/services/domain/entities/category_service_page.dart';
import 'package:dali_alsham/features/services/domain/repositories/category_service_repository.dart';

class CategoryServiceRepositoryImpl implements CategoryServiceRepository {
  const CategoryServiceRepositoryImpl(this._remoteDataSource);

  final CategoryServiceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<CategoryServicePage>> getServices({
    required int categoryId,
    required String locale,
    int page = 1,
    double? userLat,
    double? userLng,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchServices(
          categoryId: categoryId,
          locale: locale,
          page: page,
          userLat: userLat,
          userLng: userLng,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
