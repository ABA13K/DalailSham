import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../../domain/entities/vendor_service.dart';
import '../../domain/entities/vendor_service_edit.dart';
import '../../domain/repositories/vendor_repository.dart';
import '../datasources/vendor_remote_datasource.dart';

/// Talks to the vendor endpoints for the signed-in vendor's own service.
class VendorRepositoryImpl implements VendorRepository {
  VendorRepositoryImpl(this._remote);

  final VendorRemoteDataSource _remote;

  @override
  Future<Result<VendorService>> load(String locale) =>
      _run(() => _remote.service(locale));

  @override
  Future<Result<void>> update({
    required VendorServiceEdit edit,
    required String locale,
  }) => _run(() => _remote.update(edit: edit, locale: locale));

  @override
  Future<Result<void>> removeMainImage() => _run(_remote.removeMainImage);

  @override
  Future<Result<void>> changePassword(PasswordChange change) =>
      _run(() => _remote.changePassword(change));

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
