import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/services/domain/entities/category_service.dart';

/// JSON/DTO representation of [CategoryService].
class CategoryServiceModel extends CategoryService {
  const CategoryServiceModel({
    required super.id,
    required super.name,
    super.regionName,
    super.address,
    super.rating,
    super.reviewsCount,
    super.distanceText,
    super.imageUrl,
  });

  factory CategoryServiceModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! num || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid service payload');
    }

    return CategoryServiceModel(
      id: id.toInt(),
      name: name.trim(),
      regionName: _nestedName(json['region']),
      address: _text(json['address']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
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
