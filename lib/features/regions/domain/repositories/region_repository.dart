import 'package:dali_alsham/core/error/result.dart';

import '../entities/region.dart';
import '../entities/region_page.dart';

abstract interface class RegionRepository {
  /// Up to [limit] regions in random order.
  Future<Result<List<Region>>> getRandomRegions({
    required String locale,
    int limit,
  });

  /// One page of all regions.
  Future<Result<RegionPage>> getRegions({
    required String locale,
    int page,
  });
}
