import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/remote_image.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_detail.dart';

/// JSON/DTO representation of [ServiceDetail], read from the `data` block of
/// either details variant.
class ServiceDetailModel extends ServiceDetail {
  const ServiceDetailModel({
    required super.id,
    required super.name,
    required super.slug,
    super.categoryName,
    super.regionName,
    super.address,
    super.rating,
    super.reviewsCount,
    super.distanceKm,
    super.distanceText,
    super.isFavorited,
    super.isAuthenticated,
    super.mainImage,
    super.description,
    super.mapsUrl,
    super.lat,
    super.lng,
    super.isMain,
    super.visitsCount,
    super.isOpenNow,
    super.contacts,
    super.workingHours,
    super.amenities,
    super.imagesCount,
    super.productsCount,
  });

  factory ServiceDetailModel.fromEnvelope(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Missing service in response');
    }
    final id = data['id'];
    final name = data['name'];
    final slug = data['slug'];
    if (id is! num || name is! String || name.trim().isEmpty || slug is! String) {
      throw const ParseException('Invalid service payload');
    }

    return ServiceDetailModel(
      id: id.toInt(),
      name: name.trim(),
      slug: slug.trim(),
      categoryName: _nestedName(data['category']),
      regionName: _nestedName(data['region']),
      address: _text(data['address']),
      rating: (data['rating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (data['reviews_count'] as num?)?.toInt() ?? 0,
      distanceKm: (data['distance_km'] as num?)?.toDouble(),
      distanceText: _text(data['distance_text']),
      isFavorited:
          body['is_favorited'] == true || data['is_favorited'] == true,
      isAuthenticated: body['is_authenticated'] == true,
      mainImage: normalizeRemoteImageUrl(data['main_image']),
      description: _text(data['description']),
      mapsUrl: _text(data['google_maps_url']),
      lat: (data['lat'] as num?)?.toDouble(),
      lng: (data['lng'] as num?)?.toDouble(),
      isMain: data['is_main'] == true,
      visitsCount: (data['visits_count'] as num?)?.toInt() ?? 0,
      isOpenNow: data['is_open_now'] is bool ? data['is_open_now'] as bool : null,
      contacts: _contacts(data['contacts']),
      workingHours: _hours(data['working_hours']),
      amenities: _amenities(data['amenities']),
      imagesCount: _count(data['counts'], 'images_count'),
      productsCount: _count(data['counts'], 'products_count'),
    );
  }

  static List<ServiceContactGroup> _contacts(Object? value) {
    if (value is! List) return const [];
    return [
      for (final group in value)
        if (group is Map<String, dynamic>)
          ServiceContactGroup(
            type: _text(group['type']) ?? '',
            label: _text(group['type_label']) ?? _text(group['type']) ?? '',
            values: [
              for (final entry in _list(group['values']))
                if (entry is Map<String, dynamic> &&
                    _text(entry['value']) != null)
                  ServiceContactValue(
                    value: _text(entry['value'])!,
                    isPrimary: entry['is_primary'] == true,
                  ),
            ],
          ),
    ];
  }

  static List<ServiceWorkingDay> _hours(Object? value) {
    if (value is! List) return const [];
    return [
      for (final day in value)
        if (day is Map<String, dynamic> && _text(day['day']) != null)
          ServiceWorkingDay(
            day: _text(day['day'])!,
            openTime: _text(day['open_time']),
            closeTime: _text(day['close_time']),
            isClosed: day['is_closed'] == true,
          ),
    ];
  }

  static List<String> _amenities(Object? value) {
    if (value is! List) return const [];
    return [
      for (final amenity in value)
        if (amenity is Map<String, dynamic> && _text(amenity['name']) != null)
          _text(amenity['name'])!,
    ];
  }

  static int _count(Object? counts, String key) {
    if (counts is! Map<String, dynamic>) return 0;
    return (counts[key] as num?)?.toInt() ?? 0;
  }

  static List<dynamic> _list(Object? value) => value is List ? value : const [];

  static String? _nestedName(Object? value) =>
      value is Map<String, dynamic> ? _text(value['name']) : null;

  static String? _text(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}