import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';

/// JSON/DTO representation of [ExploreCategory].
class ExploreCategoryModel extends ExploreCategory {
  const ExploreCategoryModel({
    required super.id,
    required super.name,
    super.imageUrl,
    super.tagline,
  });

  factory ExploreCategoryModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! num || name is! String || name.trim().isEmpty) {
      throw const FormatException('Invalid category payload');
    }

    final phrase = json['inspirational_phrase'];
    return ExploreCategoryModel(
      id: id.toInt(),
      name: name.trim(),
      imageUrl: normalizeRemoteImageUrl(json['image']),
      tagline: phrase is String && phrase.trim().isNotEmpty
          ? phrase.trim()
          : null,
    );
  }
}
