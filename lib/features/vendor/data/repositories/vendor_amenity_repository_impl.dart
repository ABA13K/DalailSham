import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/vendor_amenity.dart';
import '../../domain/entities/vendor_amenity_edit.dart';
import '../../domain/entities/vendor_amenity_gallery.dart';
import '../../domain/repositories/vendor_amenity_repository.dart';
import '../datasources/vendor_amenity_remote_datasource.dart';

/// Talks to the vendor amenity endpoints for the signed-in vendor's service.
class VendorAmenityRepositoryImpl implements VendorAmenityRepository {
  VendorAmenityRepositoryImpl(this._remote);

  final VendorAmenityRemoteDataSource _remote;

  @override
  Future<Result<VendorAmenityGallery>> gallery({required String locale}) =>
      _run(() => _remote.gallery(locale));

  @override
  Future<Result<VendorAmenity>> add({
    required VendorAmenityEdit edit,
    required String locale,
  }) => _run(() => _remote.add(edit: edit, locale: locale));

  @override
  Future<Result<VendorAmenity>> update({
    required int id,
    required VendorAmenityEdit edit,
    required String locale,
  }) => _run(() => _remote.update(id: id, edit: edit, locale: locale));

  @override
  Future<Result<void>> remove({required int id, required String locale}) =>
      _run(() => _remote.remove(id: id, locale: locale));

  @override
  Future<Result<int>> clear({required String locale}) =>
      _run(() => _remote.clear(locale));

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
