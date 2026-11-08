import '../../../../core/error/result.dart';
import '../entities/vendor_amenity.dart';
import '../entities/vendor_amenity_edit.dart';
import '../entities/vendor_amenity_gallery.dart';

/// The amenities the signed-in vendor offers with their own service.
///
/// Every call needs the bearer token and only answers for an account whose
/// `type` is `vendor`; for anyone else the endpoints reply with an error.
abstract interface class VendorAmenityRepository {
  /// `GET /vendor/amenities`
  Future<Result<VendorAmenityGallery>> gallery({required String locale});

  /// `POST /vendor/amenities` — the new amenity waits for an admin.
  Future<Result<VendorAmenity>> add({
    required VendorAmenityEdit edit,
    required String locale,
  });

  /// `PUT /vendor/amenities/{id}` — the rewritten amenity waits for an admin
  /// again.
  Future<Result<VendorAmenity>> update({
    required int id,
    required VendorAmenityEdit edit,
    required String locale,
  });

  /// `DELETE /vendor/amenities/{id}`
  Future<Result<void>> remove({required int id, required String locale});

  /// `DELETE /vendor/amenities` — how many amenities the endpoint removed.
  Future<Result<int>> clear({required String locale});
}
