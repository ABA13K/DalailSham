import '../../domain/entities/vendor_amenity_gallery.dart';
import 'vendor_amenity_model.dart';

/// JSON/DTO representation of [VendorAmenityGallery].
class VendorAmenityGalleryModel extends VendorAmenityGallery {
  const VendorAmenityGalleryModel({
    required super.amenities,
    required super.maxAllowed,
    required super.canAdd,
  });

  factory VendorAmenityGalleryModel.fromJson(Map<String, dynamic> json) {
    final rows = json['amenities'];
    if (rows is! List) {
      throw const FormatException('Invalid vendor amenity gallery payload');
    }

    final amenities = [
      for (final row in rows.whereType<Map<String, dynamic>>())
        VendorAmenityModel.fromJson(row),
    ];

    return VendorAmenityGalleryModel(
      amenities: amenities,
      maxAllowed: (json['max_allowed'] as num?)?.toInt() ?? 0,
      // The reply says whether another amenity fits; without that word the
      // count against the limit is the only thing left to go on.
      canAdd:
          json['can_add'] == true ||
          (json['can_add'] is! bool &&
              amenities.length < ((json['max_allowed'] as num?)?.toInt() ?? 0)),
    );
  }
}
