import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../regions/domain/entities/region.dart';
import '../datasources/vendor_picker_remote_datasource.dart';
import '../../domain/repositories/vendor_picker_repository.dart';

/// Reads the two vendor pick lists the join form searches.
class VendorPickerRepositoryImpl implements VendorPickerRepository {
  VendorPickerRepositoryImpl(this._remote);

  final VendorPickerRemoteDataSource _remote;

  @override
  Future<Result<List<Region>>> regions({
    required String locale,
    String? query,
  }) => _run(() => _remote.regions(locale: locale, query: query));

  @override
  Future<Result<List<ExploreCategory>>> categories({
    required String locale,
    String? query,
  }) => _run(() => _remote.categories(locale: locale, query: query));

  Future<Result<T>> _run<T>(Future<T> Function() request) async {
    try {
      return Success(await request());
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
