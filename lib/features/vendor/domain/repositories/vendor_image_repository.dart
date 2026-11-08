import '../../../../core/error/result.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../entities/vendor_image.dart';
import '../entities/vendor_image_gallery.dart';

/// The sub-images of the signed-in vendor's own service.
///
/// Every call needs the bearer token and only answers for an account whose
/// `type` is `vendor`; for anyone else the endpoints reply with an error.
abstract interface class VendorImageRepository {
  /// `GET /vendor/images`
  Future<Result<VendorImageGallery>> gallery({required String locale});

  /// `POST /vendor/images` — the new picture waits for an admin.
  Future<Result<VendorImage>> add({
    required AvatarFile file,
    required String locale,
  });

  /// `DELETE /vendor/images/{id}`
  Future<Result<void>> remove({required int id, required String locale});

  /// `DELETE /vendor/images` — how many pictures the endpoint removed.
  Future<Result<int>> clear({required String locale});
}
