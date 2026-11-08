import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../entities/vendor_service.dart';
import '../entities/vendor_service_edit.dart';

/// The signed-in vendor's own service.
///
/// Every call needs the bearer token and only answers for an account whose
/// `type` is `vendor`; for anyone else the endpoints reply with an error.
abstract interface class VendorRepository {
  /// `GET /vendor/service`
  Future<Result<VendorService>> load(String locale);

  /// `PUT /vendor/service`
  Future<Result<void>> update({
    required VendorServiceEdit edit,
    required String locale,
  });

  /// `DELETE /vendor/service/main-image`
  Future<Result<void>> removeMainImage();

  /// `POST /vendor/service/account/change-password`
  Future<Result<void>> changePassword(PasswordChange change);
}
