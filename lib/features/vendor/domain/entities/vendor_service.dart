import 'package:equatable/equatable.dart';

/// The vendor's own service, as `GET /vendor/service` returns it.
///
/// [lat] and [lng] stay separate from [googleMapsUrl] because the endpoint
/// takes all three and answers `null` for the ones nobody filled in.
class VendorService extends Equatable {
  const VendorService({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    this.isMain = false,
    this.regionName,
    this.categoryName,
    this.addressAr,
    this.addressEn,
    this.googleMapsUrl,
    this.lat,
    this.lng,
    this.descriptionAr,
    this.descriptionEn,
    this.rating = 0,
    this.reviewsCount = 0,
    this.visitsCount = 0,
    this.subscriptionType,
    this.mainImage,
  });

  final int id;
  final String nameAr;
  final String nameEn;

  /// The vendor's headline service, the one the listings lead with.
  final bool isMain;
  final String? regionName;
  final String? categoryName;
  final String? addressAr;
  final String? addressEn;
  final String? googleMapsUrl;
  final double? lat;
  final double? lng;
  final String? descriptionAr;
  final String? descriptionEn;
  final double rating;
  final int reviewsCount;
  final int visitsCount;

  /// `free` or a paid plan; the app shows it but never edits it.
  final String? subscriptionType;
  final String? mainImage;

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    isMain,
    regionName,
    categoryName,
    addressAr,
    addressEn,
    googleMapsUrl,
    lat,
    lng,
    descriptionAr,
    descriptionEn,
    rating,
    reviewsCount,
    visitsCount,
    subscriptionType,
    mainImage,
  ];
}
