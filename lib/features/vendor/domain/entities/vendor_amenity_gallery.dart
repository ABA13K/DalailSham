import 'package:equatable/equatable.dart';

import 'vendor_amenity.dart';

/// What `GET /vendor/amenities` answers with: the amenities plus how much room
/// the service still has, so the page can say when the limit is reached
/// instead of letting the vendor write one the backend will refuse.
class VendorAmenityGallery extends Equatable {
  const VendorAmenityGallery({
    required this.amenities,
    required this.maxAllowed,
    required this.canAdd,
  });

  final List<VendorAmenity> amenities;
  final int maxAllowed;
  final bool canAdd;

  int get count => amenities.length;

  @override
  List<Object?> get props => [amenities, maxAllowed, canAdd];
}
