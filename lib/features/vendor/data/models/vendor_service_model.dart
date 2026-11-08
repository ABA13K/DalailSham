import '../../../../core/network/remote_image.dart';
import '../../domain/entities/vendor_service.dart';

/// JSON/DTO representation of [VendorService].
class VendorServiceModel extends VendorService {
  const VendorServiceModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    super.isMain,
    super.regionName,
    super.categoryName,
    super.addressAr,
    super.addressEn,
    super.googleMapsUrl,
    super.lat,
    super.lng,
    super.descriptionAr,
    super.descriptionEn,
    super.rating,
    super.reviewsCount,
    super.visitsCount,
    super.subscriptionType,
    super.mainImage,
  });

  factory VendorServiceModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nameAr = _text(json['name_ar']);
    final nameEn = _text(json['name_en']);
    if (id is! num || nameAr == null || nameEn == null) {
      throw const FormatException('Invalid vendor service payload');
    }

    return VendorServiceModel(
      id: id.toInt(),
      nameAr: nameAr,
      nameEn: nameEn,
      isMain: _flag(json['is_main']),
      regionName: _nestedName(json['region']),
      categoryName: _nestedName(json['category']),
      addressAr: _text(json['address_ar']),
      addressEn: _text(json['address_en']),
      googleMapsUrl: _text(json['google_maps_url']),
      lat: _coord(json['lat']),
      lng: _coord(json['lng']),
      descriptionAr: _text(json['description_ar']),
      descriptionEn: _text(json['description_en']),
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
      visitsCount: (json['visits_count'] as num?)?.toInt() ?? 0,
      subscriptionType: _text(json['subscription_type']),
      mainImage: normalizeRemoteImageUrl(json['main_image']),
    );
  }

  static String? _nestedName(Object? value) =>
      value is Map<String, dynamic> ? _text(value['name']) : null;

  /// The endpoint answers `true`/`false` here and `1`/`0` there.
  static bool _flag(Object? value) =>
      value == true || value == 1 || value == '1';

  /// Coordinates come back as numbers, but Laravel casts a saved string column
  /// to `"33.5138"`, so both shapes have to survive.
  static double? _coord(Object? value) {
    if (value is num) return value.toDouble();
    if (value is! String) return null;
    return double.tryParse(value.trim());
  }

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
