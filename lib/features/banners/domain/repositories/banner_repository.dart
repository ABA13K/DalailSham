import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';

abstract interface class BannerRepository {
  Future<Result<List<BannerAd>>> getBanners({required String locale});
}
