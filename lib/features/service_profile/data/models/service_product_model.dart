import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_product.dart';

/// JSON/DTO representation of [ServiceProduct].
class ServiceProductModel extends ServiceProduct {
  const ServiceProductModel({
    required super.id,
    required super.name,
    super.description,
    super.imageUrl,
    super.price,
    super.quantity,
    super.categorySlug,
    super.categoryName,
  });

  factory ServiceProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final name = json['name'];
    if (id is! num || name is! String || name.trim().isEmpty) {
      throw const ParseException('Invalid product payload');
    }
    final category = json['category'];

    return ServiceProductModel(
      id: id.toInt(),
      name: name.trim(),
      description: _text(json['description']),
      imageUrl: normalizeRemoteImageUrl(json['image']),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      categorySlug: category is Map<String, dynamic>
          ? _text(category['slug'])
          : null,
      categoryName: category is Map<String, dynamic>
          ? _text(category['name'])
          : null,
    );
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}