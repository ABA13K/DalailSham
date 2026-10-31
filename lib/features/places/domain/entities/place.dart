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

  /// Demo rating between 3.8 and 4.9, stable per place until ratings are
  /// provided by the API.
  double get rating => 3.8 + (_ratingSeed % 12) / 10;

  /// Demo number of reviews backing [rating].
  int get ratingCount => 40 + (_ratingSeed ~/ 3) % 900;

  int get _ratingSeed {
    var hash = 0;
    for (final unit in id.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return hash;
  }

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
