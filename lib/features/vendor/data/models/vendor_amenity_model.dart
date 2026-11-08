import '../../domain/entities/vendor_amenity.dart';

/// JSON/DTO representation of [VendorAmenity].
class VendorAmenityModel extends VendorAmenity {
  const VendorAmenityModel({
    required super.id,
    required super.nameAr,
    super.nameEn,
    required super.isApproved,
    super.status,
  });

  factory VendorAmenityModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    final nameAr = json['name_ar'];
    if (id is! num || nameAr is! String || nameAr.trim().isEmpty) {
      throw const FormatException('Invalid vendor amenity payload');
    }

    final status = (json['status'] as String?)?.trim();
    return VendorAmenityModel(
      id: id.toInt(),
      nameAr: nameAr.trim(),
      nameEn: (json['name_en'] as String?)?.trim(),
      // The endpoint says both how far the amenity got and which word it
      // stands under; either one alone is enough to know it reached customers.
      isApproved: json['is_approved'] == true || status == 'approved',
      status: status,
    );
  }
}
