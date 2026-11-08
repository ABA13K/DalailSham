import 'package:equatable/equatable.dart';

import 'place_category.dart';

/// A place near the user (domain entity, framework-free).
class Place extends Equatable {
  const Place({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.category,
    required this.latitude,
    required this.longitude,
    this.address,
    this.phone,
    this.website,
    this.openingHours,
    this.distanceMeters,
  });

  final String id;
  final String name;
  final String? nameAr;
  final PlaceCategory category;
  final double latitude;
  final double longitude;
  final String? address;
  final String? phone;
  final String? website;
  final String? openingHours;

  /// Distance from the user, filled in by the repository.
  final int? distanceMeters;

  /// Best display name for the given locale code (`ar` / `en`).
  String displayNameFor(String languageCode) {
    if (languageCode == 'ar' && (nameAr?.isNotEmpty ?? false)) {
      return nameAr!;
    }
    return name;
  }

  Place copyWith({int? distanceMeters}) => Place(
    id: id,
    name: name,
    nameAr: nameAr,
    category: category,
    latitude: latitude,
    longitude: longitude,
    address: address,
    phone: phone,
    website: website,
    openingHours: openingHours,
    distanceMeters: distanceMeters ?? this.distanceMeters,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    nameAr,
    category,
    latitude,
    longitude,
    address,
    phone,
    website,
    openingHours,
    distanceMeters,
  ];
}
