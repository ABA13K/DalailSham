import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/services/domain/entities/service_summary.dart';

/// JSON/DTO representation of [ServiceSummary].
class ServiceSummaryModel extends ServiceSummary {
  const ServiceSummaryModel({
    required super.id,
    required super.name,
    super.slug,
    super.regionName,
    super.categoryName,
    super.address,
    super.rating,
    super.reviewsCount,
    super.isFavorited,
    super.distanceText,
    super.imageUrl,
  });

  factory ServiceSummaryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! num || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid service payload');
    }

    return ServiceSummaryModel(
      id: id.toInt(),
      name: name.trim(),
      slug: _text(json['slug']),
      regionName: _nestedName(json['region']),
      categoryName: _nestedName(json['category']),
      address: _text(json['address']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      isFavorited: json['is_favorited'] == true,
      distanceText: _text(json['distance_text']),
      imageUrl: normalizeRemoteImageUrl(json['main_image']),
    );
  }

  static String? _nestedName(Object? value) =>
      value is Map<String, dynamic> ? _text(value['name']) : null;

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
