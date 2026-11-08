import 'package:dali_alsham/core/error/result.dart';

import '../entities/service_detail.dart';
import '../entities/service_product.dart';
import '../entities/service_review.dart';

abstract interface class ServiceProfileRepository {
  /// The service's own record. [authenticated] selects the bearer-token
  /// variant; a known location adds the distance the backend measures.
  Future<Result<ServiceDetail>> getDetail({
    required String slug,
    required String locale,
    bool authenticated,
    double? userLat,
    double? userLng,
  });

  /// The service's sub pictures, empty when it published none.
  Future<Result<List<String>>> getImages({required String slug});

  /// One page of the menu, whole or narrowed to [categorySlug].
  Future<Result<ServiceProductPage>> getProducts({
    required String slug,
    required String locale,
    required int page,
    String? categorySlug,
  });

  /// The menu categories the service actually has products under.
  Future<Result<List<ServiceProductCategory>>> getProductCategories({
    required String slug,
    required String locale,
  });

  /// One page of opinions. [authenticated] selects the variant that can mark
  /// the reader's own review.
  Future<Result<ServiceReviewPage>> getReviews({
    required String slug,
    required String locale,
    required int page,
    required ServiceReviewSort sort,
    bool authenticated,
  });
}