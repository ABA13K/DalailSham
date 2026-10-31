import 'region.dart';

/// One page of the paginated regions endpoint.
class RegionPage {
  const RegionPage({
    required this.regions,
    required this.hasMore,
    this.nextPage,
  });

  final List<Region> regions;
  final bool hasMore;
  final int? nextPage;
}
