import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';
import 'package:dali_alsham/features/banners/domain/repositories/banner_repository.dart';

class GetBanners implements UseCase<List<BannerAd>, String> {
  const GetBanners(this._repository);

  final BannerRepository _repository;

  @override
  Future<Result<List<BannerAd>>> call(String locale) =>
      _repository.getBanners(locale: locale);
}
