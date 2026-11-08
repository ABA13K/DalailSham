import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_product.dart';
import '../../domain/entities/vendor_product_edit.dart';
import '../../domain/entities/vendor_product_page.dart';
import '../../domain/entities/vendor_product_query.dart';
import '../../domain/repositories/vendor_product_repository.dart';
import '../datasources/vendor_product_remote_datasource.dart';

/// Talks to the vendor product endpoints for the signed-in vendor's service.
class VendorProductRepositoryImpl implements VendorProductRepository {
  VendorProductRepositoryImpl(this._remote);

  final VendorProductRemoteDataSource _remote;

  @override
  Future<Result<List<ExploreCategory>>> categories({
    required String locale,
    String? query,
  }) => _run(() => _remote.categories(locale: locale, query: query));

  @override
  Future<Result<VendorProductPage>> products(VendorProductQuery query) =>
      _run(() => _remote.products(query));

  @override
  Future<Result<VendorProduct>> add({
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  }) => _run(() => _remote.add(edit: edit, image: image, locale: locale));

  @override
  Future<Result<VendorProduct>> update({
    required int id,
    required VendorProductEdit edit,
    AvatarFile? image,
    required String locale,
  }) => _run(
    () => _remote.update(id: id, edit: edit, image: image, locale: locale),
  );

  @override
  Future<Result<void>> remove({required int id, required String locale}) =>
      _run(() => _remote.remove(id: id, locale: locale));

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
