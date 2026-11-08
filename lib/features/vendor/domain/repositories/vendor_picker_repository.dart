import '../../../../core/error/result.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../regions/domain/entities/region.dart';

/// The regions and categories a vendor applicant can choose from.
///
/// Public: the join form is filled before any token exists.
abstract interface class VendorPickerRepository {
  /// `GET /vendor/regions` — [query] narrows the list by name.
  Future<Result<List<Region>>> regions({required String locale, String? query});

  /// `GET /vendor/categories` — [query] narrows the list by name.
  Future<Result<List<ExploreCategory>>> categories({
    required String locale,
    String? query,
  });
}
