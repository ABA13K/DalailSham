import 'vendor_product.dart';

/// One page of `GET /vendor/products`.
class VendorProductPage {
  const VendorProductPage({
    required this.products,
    required this.hasMore,
    this.nextPage,
    this.count,
  });

  final List<VendorProduct> products;
  final bool hasMore;
  final int? nextPage;

  /// The `count` the listing answers with — how many products match the
  /// filters, not only the rows on this page.
  final int? count;
}
