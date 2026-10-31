import 'package:equatable/equatable.dart';

/// A service (business) published inside a category.
class CategoryService extends Equatable {
  const CategoryService({
    required this.id,
    required this.name,
    this.regionName,
    this.address,
    this.rating = 0,
    this.reviewsCount = 0,
    this.distanceText,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String? regionName;
  final String? address;
  final double rating;
  final int reviewsCount;

  /// Distance formatted by the backend; only present when the request carried
  /// the user's location.
  final String? distanceText;
  final String? imageUrl;

  @override
  List<Object?> get props => [
    id,
    name,
    regionName,
    address,
    rating,
    reviewsCount,
    distanceText,
    imageUrl,
  ];
}
