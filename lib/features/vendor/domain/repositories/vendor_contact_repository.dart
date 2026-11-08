import '../../../../core/error/result.dart';
import '../entities/contact_group.dart';
import '../entities/contact_type.dart';
import '../entities/vendor_contact.dart';
import '../entities/vendor_contact_edit.dart';

/// The contact lines of the signed-in vendor's own service.
///
/// Every call needs the bearer token and only answers for an account whose
/// `type` is `vendor`; for anyone else the endpoints reply with an error.
abstract interface class VendorContactRepository {
  /// `GET /vendor/contacts/types`
  Future<Result<List<ContactType>>> types({required String locale});

  /// `GET /vendor/contacts`
  Future<Result<List<ContactGroup>>> contacts({required String locale});

  /// `POST /vendor/contacts`
  Future<Result<VendorContact>> add({
    required VendorContactEdit edit,
    required String locale,
  });

  /// `PUT /vendor/contacts/{id}`
  Future<Result<VendorContact>> update({
    required int id,
    required VendorContactEdit edit,
    required String locale,
  });

  /// `DELETE /vendor/contacts/{id}`
  Future<Result<void>> remove({required int id, required String locale});

  /// `POST /vendor/contacts/{id}/set-primary`
  Future<Result<VendorContact>> setPrimary({
    required int id,
    required String locale,
  });
}
