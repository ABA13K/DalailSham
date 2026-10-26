import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/place_category.dart';
import '../models/place_model.dart';
import 'overpass_query.dart';

/// Remote data source backed by the free OpenStreetMap Overpass API.
abstract interface class PlacesRemoteDataSource {
  Future<List<PlaceModel>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  });
}

class OverpassPlacesRemoteDataSource implements PlacesRemoteDataSource {
  OverpassPlacesRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<PlaceModel>> fetchNearbyPlaces({
    required double latitude,
    required double longitude,
    required int radiusMeters,
  }) async {
    final query = buildOverpassQuery(
      latitude: latitude,
      longitude: longitude,
      radiusMeters: radiusMeters,
    );

    try {
      final response = await _dio.get<dynamic>(
        '/api/interpreter',
        queryParameters: {'data': query},
      );
      return _parse(response.data, latitude: latitude, longitude: longitude);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  AppException _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse =>
        ServerException('HTTP ${error.response?.statusCode}'),
      _ => ServerException(error.message ?? 'Request failed'),
    };
  }

  List<PlaceModel> _parse(
    Object? data, {
    required double latitude,
    required double longitude,
  }) {
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected Overpass response');
    }
    final elements = data['elements'];
    if (elements is! List) {
      throw const ParseException('Missing elements in Overpass response');
    }

    final places = <PlaceModel>[];
    for (final element in elements) {
      if (element is! Map<String, dynamic>) continue;
      final tags = element['tags'];
      if (tags is! Map<String, dynamic>) continue;

      final lat = (element['lat'] as num?)?.toDouble();
      final lon = (element['lon'] as num?)?.toDouble();
      if (lat == null || lon == null) continue;

      final id = element['id'];
      final type = element['type'];
      final name = tags['name'] as String?;
      if (name == null || name.isEmpty) continue;

      final amenity = tags['amenity'] as String?;
      final shop = tags['shop'] as String?;
      final tourism = tags['tourism'] as String?;

      places.add(
        PlaceModel(
          id: '$type/$id',
          name: name,
          nameAr: tags['name:ar'] as String?,
          category: PlaceCategory.fromOsmTags(
            amenity: amenity,
            shop: shop,
            tourism: tourism,
          ),
          latitude: lat,
          longitude: lon,
          address: _addressFrom(tags),
          phone: (tags['phone'] ?? tags['contact:phone']) as String?,
          website: (tags['website'] ?? tags['contact:website']) as String?,
          openingHours: tags['opening_hours'] as String?,
        ),
      );
    }
    return places;
  }

  String? _addressFrom(Map<String, dynamic> tags) {
    final full = tags['addr:full'] as String?;
    if (full != null && full.isNotEmpty) return full;

    final street = tags['addr:street'] as String?;
    final housenumber = tags['addr:housenumber'] as String?;
    if (street != null && housenumber != null) return '$street $housenumber';
    if (street != null) return street;

    final city = tags['addr:city'] as String?;
    return (city?.isNotEmpty ?? false) ? city : null;
  }
}
