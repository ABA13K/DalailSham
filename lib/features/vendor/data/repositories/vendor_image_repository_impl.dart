import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_image.dart';
import '../../domain/entities/vendor_image_gallery.dart';
import '../../domain/repositories/vendor_image_repository.dart';
import '../datasources/vendor_image_remote_datasource.dart';

/// Talks to the vendor sub-image endpoints for the signed-in vendor's service.
class VendorImageRepositoryImpl implements VendorImageRepository {
  VendorImageRepositoryImpl(this._remote);

  final VendorImageRemoteDataSource _remote;

  @override
  Future<Result<VendorImageGallery>> gallery({required String locale}) =>
      _run(() => _remote.gallery(locale));

  @override
  Future<Result<VendorImage>> add({
    required AvatarFile file,
    required String locale,
  }) => _run(() => _remote.add(file: file, locale: locale));

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
