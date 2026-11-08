import 'package:equatable/equatable.dart';

/// A business returned by a services listing, whether it was grouped by
/// category, by region, or came from the signed-in user's favorites.
class ServiceSummary extends Equatable {
  const ServiceSummary({
    required this.id,
    required this.name,
    this.slug,
    this.regionName,
    this.categoryName,
    this.address,
    this.rating = 0,
    this.reviewsCount = 0,
    this.isFavorited = false,
    this.distanceText,
    this.imageUrl,
  });

  final int id;
  final String name;

  /// URL identifier used by the favorites endpoints.
  final String? slug;

  /// Present when the listing did not already come from a region.
  final String? regionName;

  /// Present when the listing did not already come from a category.
  final String? categoryName;

  final String? address;
  final double rating;
  final int reviewsCount;
  final bool isFavorited;

  /// Distance formatted by the backend; only present when the request carried
  /// the user's location.
  final String? distanceText;
  final String? imageUrl;

  ServiceSummary copyWith({bool? isFavorited}) => ServiceSummary(
    id: id,
    name: name,
    slug: slug,
    regionName: regionName,
    categoryName: categoryName,
    address: address,
    rating: rating,
    reviewsCount: reviewsCount,
    isFavorited: isFavorited ?? this.isFavorited,
    distanceText: distanceText,
    imageUrl: imageUrl,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    regionName,
    categoryName,
    address,
    rating,
    reviewsCount,
    isFavorited,
    distanceText,
    imageUrl,
  ];
}
