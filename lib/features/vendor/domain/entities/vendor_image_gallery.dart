import 'package:equatable/equatable.dart';

import 'vendor_image.dart';

/// What `GET /vendor/images` answers with: the pictures plus how much room the
/// service still has, so the page can say when the limit is reached instead of
/// letting the vendor pick a photo the backend will refuse.
class VendorImageGallery extends Equatable {
  const VendorImageGallery({
    required this.images,
    required this.maxAllowed,
    required this.canAdd,
  });

  final List<VendorImage> images;
  final int maxAllowed;
  final bool canAdd;

  int get count => images.length;

  @override
  List<Object?> get props => [images, maxAllowed, canAdd];
}
