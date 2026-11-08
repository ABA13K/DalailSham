import 'package:equatable/equatable.dart';

/// What `POST /vendor/products` and `PUT /vendor/products/{id}` are sent.
///
/// The picture travels beside these fields as a multipart part, so it is not
/// held here — a write that picked one passes it along separately.
class VendorProductEdit extends Equatable {
  const VendorProductEdit({
    required this.categoryId,
    required this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    required this.price,
    this.quantity,
    this.isActive,
    this.isAvailable,
  });

  final int categoryId;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final double price;
  final int? quantity;

  /// Null means the field is not sent at all, which is what `sometimes` asks
  /// for on the edit call.
  final bool? isActive;
  final bool? isAvailable;

  @override
  List<Object?> get props => [
    categoryId,
    nameAr,
    nameEn,
    descriptionAr,
    descriptionEn,
    price,
    quantity,
    isActive,
    isAvailable,
  ];
}
