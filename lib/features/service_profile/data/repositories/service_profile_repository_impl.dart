import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/service_profile/data/datasources/service_profile_remote_datasource.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_detail.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_product.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_review.dart';
import 'package:dali_alsham/features/service_profile/domain/repositories/service_profile_repository.dart';

class ServiceProfileRepositoryImpl implements ServiceProfileRepository {
  const ServiceProfileRepositoryImpl(this._remoteDataSource);

  final ServiceProfileRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ServiceDetail>> getDetail({
    required String slug,
    required String locale,
    bool authenticated = false,
    double? userLat,
    double? userLng,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchDetail(
          slug: slug,
          locale: locale,
          authenticated: authenticated,
          userLat: userLat,
          userLng: userLng,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<List<String>>> getImages({required String slug}) async {
    try {
      return Success(await _remoteDataSource.fetchImages(slug: slug));
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<ServiceProductPage>> getProducts({
    required String slug,
    required String locale,
    required int page,
    String? categorySlug,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchProducts(
          slug: slug,
          locale: locale,
          page: page,
          categorySlug: categorySlug,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<List<ServiceProductCategory>>> getProductCategories({
    required String slug,
    required String locale,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchProductCategories(
          slug: slug,
          locale: locale,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<Result<ServiceReviewPage>> getReviews({
    required String slug,
    required String locale,
    required int page,
    required ServiceReviewSort sort,
    bool authenticated = false,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchReviews(
          slug: slug,
          locale: locale,
          page: page,
          sort: sort,
          authenticated: authenticated,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}