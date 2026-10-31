import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/regions/data/datasources/region_remote_datasource.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/regions/domain/entities/region_page.dart';
import 'package:dali_alsham/features/regions/domain/repositories/region_repository.dart';

class RegionRepositoryImpl implements RegionRepository {
  const RegionRepositoryImpl(this._remoteDataSource);

  final RegionRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<Region>>> getRandomRegions({
    required String locale,
    int limit = 8,
  }) async {
    try {
      final random = await _remoteDataSource.fetchRandomRegions(
        locale: locale,
      );
      return Success(random.take(limit).toList());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<RegionPage>> getRegions({
    required String locale,
    int page = 1,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchRegions(locale: locale, page: page),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
