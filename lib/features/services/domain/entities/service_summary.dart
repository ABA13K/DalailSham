import 'package:equatable/equatable.dart';

/// A business returned by a services listing, whether it was grouped by
/// category or by region.
class ServiceSummary extends Equatable {
  const ServiceSummary({
    required this.id,
    required this.name,
    this.regionName,
    this.categoryName,
    this.address,
    this.rating = 0,
    this.reviewsCount = 0,
    this.distanceText,
    this.imageUrl,
  });

  final int id;
  final String name;

  /// Present when the listing did not already come from a region.
  final String? regionName;

  /// Present when the listing did not already come from a category.
  final String? categoryName;

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
    categoryName,
    address,
    rating,
    reviewsCount,
    distanceText,
    imageUrl,
  ];
}
