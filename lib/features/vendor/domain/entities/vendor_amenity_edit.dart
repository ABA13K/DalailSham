import 'package:equatable/equatable.dart';

/// What `POST /vendor/amenities` and `PUT /vendor/amenities/{id}` take: the two
/// names, nothing else. The Arabic half is the one the backend requires.
class VendorAmenityEdit extends Equatable {
  const VendorAmenityEdit({required this.nameAr, this.nameEn});

  final String nameAr;
  final String? nameEn;

  @override
  List<Object?> get props => [nameAr, nameEn];
}
