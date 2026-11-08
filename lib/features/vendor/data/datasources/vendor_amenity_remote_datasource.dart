import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/vendor_amenity.dart';
import '../../domain/entities/vendor_amenity_edit.dart';
import '../../domain/entities/vendor_amenity_gallery.dart';
import '../models/vendor_amenity_gallery_model.dart';
import '../models/vendor_amenity_model.dart';

/// What the five vendor amenity endpoints answer.
abstract interface class VendorAmenityRemoteDataSource {
  /// `GET /vendor/amenities`
  Future<VendorAmenityGallery> gallery(String locale);

  /// `POST /vendor/amenities`
  Future<VendorAmenity> add({
    required VendorAmenityEdit edit,
    required String locale,
  });

  /// `PUT /vendor/amenities/{id}`
  Future<VendorAmenity> update({
    required int id,
    required VendorAmenityEdit edit,
    required String locale,
  });

  /// `DELETE /vendor/amenities/{id}`
  Future<void> remove({required int id, required String locale});

  /// `DELETE /vendor/amenities` — the reply counts what it removed.
  Future<int> clear(String locale);
}

/// Remote data source backed by the Dali Alsham vendor amenity endpoints.
///
/// All five are authenticated and scoped to the signed-in vendor's own
/// service; the shared Dio carries the bearer token through `AuthInterceptor`.
class DalilVendorAmenityRemoteDataSource
    implements VendorAmenityRemoteDataSource {
  DalilVendorAmenityRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<VendorAmenityGallery> gallery(String locale) async {
    final body = await _reply(
      () => _dio.get<dynamic>(
        ApiConstants.vendorAmenitiesPath,
        queryParameters: _localeQuery(locale),
      ),
    );
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Vendor amenities reply carried no gallery');
    }
    try {
      return VendorAmenityGalleryModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Vendor amenities reply carried no gallery');
    }
  }

  @override
  Future<VendorAmenity> add({
    required VendorAmenityEdit edit,
    required String locale,
  }) => _written(
    () => _dio.post<dynamic>(
      ApiConstants.vendorAmenitiesPath,
      data: _fields(edit),
      queryParameters: _localeQuery(locale),
    ),
  );

  @override
  Future<VendorAmenity> update({
    required int id,
    required VendorAmenityEdit edit,
    required String locale,
  }) => _written(
    () => _dio.put<dynamic>(
      ApiConstants.vendorAmenityPath(id),
      data: _fields(edit),
      queryParameters: _localeQuery(locale),
    ),
  );

  @override
  Future<void> remove({required int id, required String locale}) async {
    await _reply(
      () => _dio.delete<dynamic>(
        ApiConstants.vendorAmenityPath(id),
        queryParameters: _localeQuery(locale),
      ),
    );
  }

  @override
  Future<int> clear(String locale) async {
    final body = await _reply(
      () => _dio.delete<dynamic>(
        ApiConstants.vendorAmenitiesPath,
        queryParameters: _localeQuery(locale),
      ),
    );
    final data = body?['data'];
    return data is Map<String, dynamic>
        ? (data['deleted'] as num?)?.toInt() ?? 0
        : 0;
  }

  /// An amenity is two names and nothing else, so it travels as plain JSON
  /// rather than the multipart form a picture needs.
  static Map<String, String> _fields(VendorAmenityEdit edit) =>
      <String, String>{
        'name_ar': edit.nameAr,
        'name_en': edit.nameEn?.trim() ?? '',
      };

  /// A write answers with the line it stored, so the page shows the id and the
  /// approval state the server chose instead of guessing them.
  Future<VendorAmenity> _written(
    Future<Response<dynamic>> Function() request,
  ) async {
    final body = await _reply(request);
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Amenity reply carried no amenity');
    }
    try {
      return VendorAmenityModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Amenity reply carried no amenity');
    }
  }

  Future<Map<String, dynamic>?> _reply(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return _body(await request());
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  static Map<String, String> _localeQuery(String locale) => <String, String>{
    'locale': locale,
  };

  static Map<String, dynamic>? _body(Response<dynamic>? response) =>
      response?.data is Map<String, dynamic>
      ? response!.data as Map<String, dynamic>
      : null;

  /// A validation reply names the offending field, which says more than the
  /// generic `message` the endpoint returns alongside it.
  static String _message(Map<String, dynamic>? body) {
    final errors = body?['errors'];
    if (errors is Map) {
      for (final messages in errors.values) {
        final first = messages is List && messages.isNotEmpty
            ? messages.first
            : null;
        if (first is String && first.trim().isNotEmpty) return first.trim();
      }
    }
    return (body?['message'] as String?)?.trim() ?? '';
  }

  AppException _mapDioException(DioException error) {
    if (error.type == DioExceptionType.badResponse) {
      final message = _message(_body(error.response));
      return ServerException(
        message.isEmpty ? 'HTTP ${error.response?.statusCode}' : message,
      );
    }
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      _ => ServerException(error.message ?? 'Request failed'),
    };
  }
}
