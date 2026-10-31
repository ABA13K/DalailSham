import 'category_service.dart';

/// One page of the paginated category services endpoint.
class CategoryServicePage {
  const CategoryServicePage({
    required this.services,
    required this.hasMore,
    this.nextPage,
  });

  final List<CategoryService> services;
  final bool hasMore;
  final int? nextPage;
}
