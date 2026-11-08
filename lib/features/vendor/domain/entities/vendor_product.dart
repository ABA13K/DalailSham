import 'package:equatable/equatable.dart';

/// One thing the vendor sells, as `GET /vendor/products` answers it.
///
/// A product is written in both languages and the backend only insists on the
/// Arabic half, so [nameEn] and the two descriptions can come back null.
class VendorProduct extends Equatable {
  const VendorProduct({
    required this.id,
    required this.nameAr,
    this.nameEn,
    this.descriptionAr,
    this.descriptionEn,
    this.categoryId,
    this.categoryName,
    required this.price,
    this.quantity,
    this.imageUrl,
    this.isActive = true,
    this.isAvailable = true,
    this.isApproved = false,
  });

  final int id;
  final String nameAr;
  final String? nameEn;
  final String? descriptionAr;
  final String? descriptionEn;
  final int? categoryId;
  final String? categoryName;

  /// What one unit costs, in the currency the shop already quotes in.
  final double price;

  /// How many are in stock; the endpoint leaves it out when the vendor does not
  /// count them.
  final int? quantity;
  final String? imageUrl;
  final bool isActive;
  final bool isAvailable;

  /// Whether an admin has let the product reach customers yet.
  final bool isApproved;

  /// The Arabic name is the one the backend requires, so it stands in for a
  /// missing English half instead of showing a blank row.
  String nameIn(String locale) {
    final english = nameEn?.trim();
    if (locale == 'ar' || english == null || english.isEmpty) return nameAr;
    return english;
  }

  String? descriptionIn(String locale) {
    String? nonEmpty(String? text) =>
        text == null || text.trim().isEmpty ? null : text.trim();
    return nonEmpty(locale == 'ar' ? descriptionAr : descriptionEn) ??
        nonEmpty(locale == 'ar' ? descriptionEn : descriptionAr);
  }

  @override
  List<Object?> get props => [
    id,
    nameAr,
    nameEn,
    descriptionAr,
    descriptionEn,
    categoryId,
    categoryName,
    price,
    quantity,
    imageUrl,
    isActive,
    isAvailable,
    isApproved,
  ];
}
