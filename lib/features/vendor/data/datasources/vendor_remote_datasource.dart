import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../../domain/entities/vendor_service_edit.dart';
import '../models/vendor_service_model.dart';

/// What `PUT /vendor/service` accepts; the reply echoes it minus region and
/// category, so the cubit reloads the full record after saving.
abstract interface class VendorRemoteDataSource {
  /// `GET /vendor/service`
  Future<VendorServiceModel> service(String locale);

  /// `PUT /vendor/service`
  Future<void> update({
    required VendorServiceEdit edit,
    required String locale,
  });

  /// `DELETE /vendor/service/main-image`
  Future<void> removeMainImage();

  /// `POST /vendor/service/account/change-password`
  Future<void> changePassword(PasswordChange change);
}

/// Remote data source backed by the Dali Alsham vendor endpoints.
///
/// All four are authenticated and scoped to the signed-in vendor's own service;
/// the shared Dio carries the bearer token through `AuthInterceptor`.
class DalilVendorRemoteDataSource implements VendorRemoteDataSource {
  DalilVendorRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<VendorServiceModel> service(String locale) async {
    final body = await _reply(
      () => _dio.get<dynamic>(
        ApiConstants.vendorServicePath,
        queryParameters: _localeQuery(locale),
      ),
    );
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Vendor service reply carried no service');
    }
    try {
      return VendorServiceModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Vendor service reply carried no service');
    }
  }

  @override
  Future<void> update({
    required VendorServiceEdit edit,
    required String locale,
  }) => _reply(
    () => _dio.put<dynamic>(
      ApiConstants.vendorServicePath,
      data: <String, dynamic>{
        'name_ar': edit.nameAr,
        'name_en': edit.nameEn,
        'address_ar': edit.addressAr,
        'address_en': edit.addressEn,
        'google_maps_url': edit.googleMapsUrl,
        'lat': edit.lat,
        'lng': edit.lng,
        'description_ar': edit.descriptionAr,
        'description_en': edit.descriptionEn,
      },
      queryParameters: _localeQuery(locale),
    ),
  );

  @override
  Future<void> removeMainImage() => _reply(
    () => _dio.delete<dynamic>(ApiConstants.vendorMainImagePath),
    // 404 says there was no picture to delete, which is where the caller
    // wanted the service to be.
    absentIsDone: true,
  );

  @override
  Future<void> changePassword(PasswordChange change) => _reply(
    () => _dio.post<dynamic>(
      ApiConstants.vendorAccountPasswordPath,
      data: <String, dynamic>{
        'current_password': change.currentPassword,
        'password': change.password,
        'password_confirmation': change.confirmation,
      },
    ),
  );

  Future<Map<String, dynamic>?> _reply(
    Future<Response<dynamic>> Function() request, {
    bool absentIsDone = false,
  }) async {
    try {
      return _body(await request());
    } on DioException catch (error) {
      if (absentIsDone && error.response?.statusCode == 404) return null;
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
