import 'package:dali_alsham/features/places/domain/entities/place.dart';
import 'package:dali_alsham/features/places/domain/entities/place_category.dart';

/// JSON/DTO representation of [Place].
class PlaceModel extends Place {
  const PlaceModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.category,
    required super.latitude,
    required super.longitude,
    super.address,
    super.phone,
    super.website,
    super.openingHours,
    super.distanceMeters,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    final lat = json['lat'] as num?;
    final lon = json['lon'] as num?;
    if (lat == null || lon == null) {
      throw const FormatException('Place is missing coordinates');
    }
    return PlaceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      category: PlaceCategory.values.firstWhere(
        (value) => value.name == json['category'],
        orElse: () => PlaceCategory.other,
      ),
      latitude: lat.toDouble(),
      longitude: lon.toDouble(),
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      website: json['website'] as String?,
      openingHours: json['openingHours'] as String?,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameAr': nameAr,
        'category': category.name,
        'lat': latitude,
        'lon': longitude,
        'address': address,
        'phone': phone,
        'website': website,
        'openingHours': openingHours,
        'distanceMeters': distanceMeters,
      };

  PlaceModel copyWithDistance(int meters) => PlaceModel(
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
        distanceMeters: meters,
      );
}
