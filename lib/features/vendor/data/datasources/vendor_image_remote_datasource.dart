import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../profile/domain/entities/avatar_file.dart';
import '../../domain/entities/vendor_image.dart';
import '../../domain/entities/vendor_image_gallery.dart';
import '../models/vendor_image_gallery_model.dart';
import '../models/vendor_image_model.dart';

/// What the four vendor sub-image endpoints answer.
abstract interface class VendorImageRemoteDataSource {
  /// `GET /vendor/images`
  Future<VendorImageGallery> gallery(String locale);

  /// `POST /vendor/images`
  Future<VendorImage> add({required AvatarFile file, required String locale});

  /// `DELETE /vendor/images/{id}`
  Future<void> remove({required int id, required String locale});

  /// `DELETE /vendor/images` — the reply counts what it removed.
  Future<int> clear(String locale);
}

/// Remote data source backed by the Dali Alsham vendor sub-image endpoints.
///
/// All four are authenticated and scoped to the signed-in vendor's own service;
/// the shared Dio carries the bearer token through `AuthInterceptor`.
class DalilVendorImageRemoteDataSource implements VendorImageRemoteDataSource {
  DalilVendorImageRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<VendorImageGallery> gallery(String locale) async {
    final body = await _reply(
      () => _dio.get<dynamic>(
        ApiConstants.vendorImagesPath,
        queryParameters: _localeQuery(locale),
      ),
    );
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Vendor images reply carried no gallery');
    }
    try {
      return VendorImageGalleryModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Vendor images reply carried no gallery');
    }
  }

  @override
  Future<VendorImage> add({
    required AvatarFile file,
    required String locale,
  }) async {
    final body = await _reply(
      () => _dio.post<dynamic>(
        ApiConstants.vendorImagesPath,
        data: FormData.fromMap(<String, dynamic>{
          'image': MultipartFile.fromBytes(file.bytes, filename: file.fileName),
        }),
        queryParameters: _localeQuery(locale),
      ),
    );
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Vendor image reply carried no image');
    }
    try {
      return VendorImageModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Vendor image reply carried no image');
    }
  }

  @override
  Future<void> remove({required int id, required String locale}) async {
    await _reply(
      () => _dio.delete<dynamic>(
        ApiConstants.vendorImagePath(id),
        queryParameters: _localeQuery(locale),
      ),
    );
  }

  @override
  Future<int> clear(String locale) async {
    final body = await _reply(
      () => _dio.delete<dynamic>(
        ApiConstants.vendorImagesPath,
        queryParameters: _localeQuery(locale),
      ),
    );
    final data = body?['data'];
    return data is Map<String, dynamic>
        ? (data['deleted'] as num?)?.toInt() ?? 0
        : 0;
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
