import '../../domain/entities/vendor_image_gallery.dart';
import 'vendor_image_model.dart';

/// JSON/DTO representation of [VendorImageGallery].
class VendorImageGalleryModel extends VendorImageGallery {
  const VendorImageGalleryModel({
    required super.images,
    required super.maxAllowed,
    required super.canAdd,
  });

  factory VendorImageGalleryModel.fromJson(Map<String, dynamic> json) {
    final rows = json['images'];
    if (rows is! List) {
      throw const FormatException('Invalid vendor image gallery payload');
    }

    final images = [
      for (final row in rows.whereType<Map<String, dynamic>>())
        VendorImageModel.fromJson(row),
    ];

    return VendorImageGalleryModel(
      images: images,
      maxAllowed: (json['max_allowed'] as num?)?.toInt() ?? 0,
      // The reply says whether another picture fits; without that word the
      // count against the limit is the only thing left to go on.
      canAdd:
          json['can_add'] == true ||
          (json['can_add'] is! bool &&
              images.length < ((json['max_allowed'] as num?)?.toInt() ?? 0)),
    );
  }
}
