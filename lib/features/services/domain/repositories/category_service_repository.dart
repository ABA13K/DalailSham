import 'package:dali_alsham/core/error/result.dart';

import '../entities/category_service_page.dart';

abstract interface class CategoryServiceRepository {
  /// One page of the services published in [categoryId].
  ///
  /// When both [userLat] and [userLng] are given the backend sorts the list by
  /// distance and returns a distance label per service.
  Future<Result<CategoryServicePage>> getServices({
    required int categoryId,
    required String locale,
    int page,
    double? userLat,
    double? userLng,
  });
}
