import '../../../../core/network/remote_image.dart';
import '../../domain/entities/vendor_product.dart';

/// JSON/DTO representation of [VendorProduct].
class VendorProductModel extends VendorProduct {
  const VendorProductModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    super.descriptionAr,
    super.descriptionEn,
    super.categoryId,
    super.categoryName,
    required super.price,
    super.quantity,
    super.imageUrl,
    super.isActive,
    super.isAvailable,
    super.isApproved,
  });

  factory VendorProductModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nameAr = _text(json['name_ar']);
    // A row without a name in either language is not a product the vendor can
    // show, so the listing fails rather than rendering a blank card.
    if (id is! num || nameAr == null) {
      throw const FormatException('Invalid vendor product payload');
    }

    final category = json['category'];

    return VendorProductModel(
      id: id.toInt(),
      nameAr: nameAr,
      nameEn: _text(json['name_en']),
      descriptionAr: _text(json['description_ar']),
      descriptionEn: _text(json['description_en']),
      categoryId: category is Map<String, dynamic>
          ? (category['id'] as num?)?.toInt()
          : null,
      categoryName: category is Map<String, dynamic>
          ? _text(category['name'])
          : null,
      price: _money(json['price']) ?? 0,
      quantity: _whole(json['quantity']),
      imageUrl: normalizeRemoteImageUrl(json['image']),
      isActive: _flag(json['is_active']),
      isAvailable: _flag(json['is_available']),
      isApproved: _flag(json['is_approved']),
    );
  }

  /// Prices arrive as JSON numbers but a decimal column can answer `"100.00"`.
  static double? _money(Object? value) {
    if (value is num) return value.toDouble();
    if (value is! String) return null;
    return double.tryParse(value.trim());
  }

  static int? _whole(Object? value) {
    if (value is num) return value.toInt();
    if (value is! String) return null;
    return int.tryParse(value.trim());
  }

  /// The endpoint answers `true`/`false` for these and `1`/`0` elsewhere.
  static bool _flag(Object? value) =>
      value == true || value == 1 || value == '1';

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
