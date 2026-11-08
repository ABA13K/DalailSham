import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/contact_group.dart';
import '../../domain/entities/contact_type.dart';
import '../../domain/entities/vendor_contact.dart';
import '../../domain/entities/vendor_contact_edit.dart';
import '../../domain/repositories/vendor_contact_repository.dart';
import '../datasources/vendor_contact_remote_datasource.dart';

/// Talks to the vendor contact endpoints for the signed-in vendor's own service.
class VendorContactRepositoryImpl implements VendorContactRepository {
  VendorContactRepositoryImpl(this._remote);

  final VendorContactRemoteDataSource _remote;

  @override
  Future<Result<List<ContactType>>> types({required String locale}) =>
      _run(() => _remote.types(locale));

  @override
  Future<Result<List<ContactGroup>>> contacts({required String locale}) =>
      _run(() => _remote.contacts(locale));

  @override
  Future<Result<VendorContact>> add({
    required VendorContactEdit edit,
    required String locale,
  }) => _run(() => _remote.add(edit: edit, locale: locale));

  @override
  Future<Result<VendorContact>> update({
    required int id,
    required VendorContactEdit edit,
    required String locale,
  }) => _run(() => _remote.update(id: id, edit: edit, locale: locale));

  @override
  Future<Result<void>> remove({required int id, required String locale}) =>
      _run(() => _remote.remove(id: id, locale: locale));

  @override
  Future<Result<VendorContact>> setPrimary({
    required int id,
    required String locale,
  }) => _run(() => _remote.setPrimary(id: id, locale: locale));

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
