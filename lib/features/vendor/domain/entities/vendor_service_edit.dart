import 'package:equatable/equatable.dart';

/// `PUT /vendor/service` payload — the nine fields the endpoint edits.
///
/// The two names are `required` there, so they are non-nullable here; the rest
/// are `nullable` and go out as `null` when the vendor clears them.
class VendorServiceEdit extends Equatable {
  const VendorServiceEdit({
    required this.nameAr,
    required this.nameEn,
    this.addressAr,
    this.addressEn,
    this.googleMapsUrl,
    this.lat,
    this.lng,
    this.descriptionAr,
    this.descriptionEn,
  });

  final String nameAr;
  final String nameEn;
  final String? addressAr;
  final String? addressEn;
  final String? googleMapsUrl;
  final double? lat;
  final double? lng;
  final String? descriptionAr;
  final String? descriptionEn;

  @override
  List<Object?> get props => [
    nameAr,
    nameEn,
    addressAr,
    addressEn,
    googleMapsUrl,
    lat,
    lng,
    descriptionAr,
    descriptionEn,
  ];
}
