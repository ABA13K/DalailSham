import 'package:equatable/equatable.dart';

/// One product as customers see it inside a service's menu.
class ServiceProduct extends Equatable {
  const ServiceProduct({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.price = 0,
    this.quantity = 0,
    this.categorySlug,
    this.categoryName,
  });

  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double price;
  final int quantity;
  final String? categorySlug;
  final String? categoryName;

  bool get inStock => quantity > 0;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    price,
    quantity,
    categorySlug,
    categoryName,
  ];
}

/// One page of a service's products, whole or narrowed to one category.
class ServiceProductPage {
  const ServiceProductPage({
    required this.products,
    required this.hasMore,
    this.nextPage,
    this.total = 0,
  });

  final List<ServiceProduct> products;
  final bool hasMore;
  final int? nextPage;
  final int total;
}

/// A menu category with how many products the service filed under it.
class ServiceProductCategory extends Equatable {
  const ServiceProductCategory({
    required this.slug,
    required this.name,
    this.productsCount = 0,
  });

  final String slug;
  final String name;
  final int productsCount;

  @override
  List<Object?> get props => [slug, name, productsCount];
}