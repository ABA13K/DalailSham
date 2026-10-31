import 'explore_category.dart';

/// One page of the paginated categories endpoint.
class CategoryPage {
  const CategoryPage({
    required this.categories,
    required this.hasMore,
    this.nextPage,
  });

  final List<ExploreCategory> categories;
  final bool hasMore;
  final int? nextPage;
}
