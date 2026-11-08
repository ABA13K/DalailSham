import 'package:equatable/equatable.dart';

/// How `GET /vendor/products` narrows its rows by approval, spelled the way the
/// `status` parameter spells it.
///
/// The contract shows `pending`; the other two are the states a product can
/// leave that pending set in, named after the `is_approved` flag the rows carry.
enum VendorProductStatus {
  pending('pending'),
  approved('approved'),
  rejected('rejected');

  const VendorProductStatus(this.wire);

  final String wire;
}

/// One request to the vendor products listing: the words typed in the field, the
/// category chosen and the approval state asked for.
///
/// A filter left null is not sent, so the backend answers with its own default.
class VendorProductQuery extends Equatable {
  const VendorProductQuery({
    required this.locale,
    this.page = 1,
    this.perPage = 20,
    this.categoryId,
    this.status,
    this.text = '',
  });

  final String locale;
  final int page;
  final int perPage;
  final int? categoryId;
  final VendorProductStatus? status;
  final String text;

  bool get hasFilters => categoryId != null || status != null;

  @override
  List<Object?> get props => [locale, page, perPage, categoryId, status, text];
}
