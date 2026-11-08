import '../../../../core/network/remote_image.dart';
import '../../domain/entities/vendor_image.dart';

/// JSON/DTO representation of [VendorImage].
class VendorImageModel extends VendorImage {
  const VendorImageModel({
    required super.id,
    required super.url,
    required super.isApproved,
    required super.sortOrder,
  });

  factory VendorImageModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final url = normalizeRemoteImageUrl(json['image']);
    if (id is! num || url == null) {
      throw const FormatException('Invalid vendor image payload');
    }

    return VendorImageModel(
      id: id.toInt(),
      url: url,
      isApproved: json['is_approved'] == true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }
}
