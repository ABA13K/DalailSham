import 'package:equatable/equatable.dart';

import 'service_sort.dart';

/// One request to the services search endpoint: the words typed in the field
/// plus the filters that narrow them.
///
/// A filter left null is not sent at all, so the backend chooses its own
/// default for it. `minRating` of `0` is sent, because asking for "any rating"
/// and asking for nothing are different requests.
class ServiceSearchQuery extends Equatable {
  const ServiceSearchQuery({
    required this.text,
    required this.locale,
    this.page = 1,
    this.authenticated = false,
    this.userLat,
    this.userLng,
    this.categoryId,
    this.regionId,
    this.sort,
    this.minRating,
  });

  final String text;
  final String locale;
  final int page;

  /// Whether a bearer token is stored, which selects the signed-in search that
  /// reports the favorite flag of every result.
  final bool authenticated;
  final double? userLat;
  final double? userLng;
  final int? categoryId;
  final int? regionId;
  final ServiceSort? sort;
  final double? minRating;

  bool get hasFilters =>
      categoryId != null ||
      regionId != null ||
      sort != null ||
      minRating != null;

  @override
  List<Object?> get props => [
    text,
    locale,
    page,
    authenticated,
    userLat,
    userLng,
    categoryId,
    regionId,
    sort,
    minRating,
  ];
}
