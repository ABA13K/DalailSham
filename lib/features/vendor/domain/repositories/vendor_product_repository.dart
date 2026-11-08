import '../../../../core/error/result.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../entities/vendor_product.dart';
import '../entities/vendor_product_edit.dart';
import '../entities/vendor_product_page.dart';
import '../entities/vendor_product_query.dart';

/// The products the signed-in vendor sells, and the categories they file under.
///
/// Every call needs the bearer token and only answers for an account whose
/// `type` is `vendor`; for anyone else the endpoints reply with an error.
abstract interface class VendorProductRepository {
  /// `GET /vendor/product-categories` — [query] narrows the names.
  Future<Result<List<ExploreCategory>>> categories({
    required String locale,
    String? query,
  });

  /// `GET /vendor/products` — one page of the listing, filters applied.
  Future<Result<VendorProductPage>> products(VendorProductQuery query);

  /// `POST /vendor/products` — the new product waits for an admin.
  Future<Result<VendorProduct>> add({
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  });

  /// `PUT /vendor/products/{id}`
  Future<Result<VendorProduct>> update({
    required int id,
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  });

  /// `DELETE /vendor/products/{id}`
  Future<Result<void>> remove({required int id, required String locale});
}
