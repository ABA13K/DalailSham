import 'package:equatable/equatable.dart';

/// One thing the vendor offers with their service, as `GET /vendor/amenities`
/// answers it.
///
/// The backend only insists on the Arabic name, so [nameEn] can come back
/// null. A new or rewritten amenity waits for an admin before customers see
/// it, and [status] carries the server's own word for which side of that it
/// is on.
class VendorAmenity extends Equatable {
  const VendorAmenity({
    required this.id,
    required this.nameAr,
    this.nameEn,
    required this.isApproved,
    this.status,
  });

  final int id;
  final String nameAr;
  final String? nameEn;
  final bool isApproved;
  final String? status;

  /// The Arabic name is the one the backend requires, so it stands in for a
  /// missing English half instead of showing a blank row.
  String nameIn(String locale) {
    final english = nameEn?.trim();
    if (locale == 'ar' || english == null || english.isEmpty) return nameAr;
    return english;
  }

  /// The name in the other language, when the vendor wrote one, so a row can
  /// show both halves the endpoint holds.
  String? otherName(String locale) {
    final secondary = (locale == 'ar' ? nameEn : nameAr)?.trim();
    final primary = nameIn(locale);
    if (secondary == null || secondary.isEmpty || secondary == primary) {
      return null;
    }
    return secondary;
  }

  @override
  List<Object?> get props => [id, nameAr, nameEn, isApproved, status];
}
