import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/banners/data/datasources/banner_remote_datasource.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';
import 'package:dali_alsham/features/banners/domain/repositories/banner_repository.dart';

class BannerRepositoryImpl implements BannerRepository {
  const BannerRepositoryImpl(this._remoteDataSource);

  final BannerRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<BannerAd>>> getBanners({required String locale}) async {
    try {
      return Success(await _remoteDataSource.fetchBanners(locale: locale));
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
