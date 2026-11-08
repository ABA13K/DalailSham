import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/contact_group.dart';
import '../../domain/entities/contact_type.dart';
import '../../domain/entities/vendor_contact.dart';
import '../../domain/entities/vendor_contact_edit.dart';
import '../models/contact_group_model.dart';
import '../models/contact_type_model.dart';
import '../models/vendor_contact_model.dart';

/// What the six vendor contact endpoints answer.
abstract interface class VendorContactRemoteDataSource {
  /// `GET /vendor/contacts/types`
  Future<List<ContactType>> types(String locale);

  /// `GET /vendor/contacts`
  Future<List<ContactGroup>> contacts(String locale);

  /// `POST /vendor/contacts`
  Future<VendorContact> add({
    required VendorContactEdit edit,
    required String locale,
  });

  /// `PUT /vendor/contacts/{id}`
  Future<VendorContact> update({
    required int id,
    required VendorContactEdit edit,
    required String locale,
  });

  /// `DELETE /vendor/contacts/{id}`
  Future<void> remove({required int id, required String locale});

  /// `POST /vendor/contacts/{id}/set-primary`
  Future<VendorContact> setPrimary({required int id, required String locale});
}

/// Remote data source backed by the Dali Alsham vendor contact endpoints.
///
/// All six are authenticated and scoped to the signed-in vendor's own service;
/// the shared Dio carries the bearer token through `AuthInterceptor`.
class DalilVendorContactRemoteDataSource
    implements VendorContactRemoteDataSource {
  DalilVendorContactRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<ContactType>> types(String locale) async {
    final body = await _reply(
      () => _dio.get<dynamic>(
        ApiConstants.vendorContactTypesPath,
        queryParameters: _localeQuery(locale),
      ),
    );
    return _rows(body, 'contact type list', ContactTypeModel.fromJson);
  }

  @override
  Future<List<ContactGroup>> contacts(String locale) async {
    final body = await _reply(
      () => _dio.get<dynamic>(
        ApiConstants.vendorContactsPath,
        queryParameters: _localeQuery(locale),
      ),
    );
    return _rows(body, 'contact group list', ContactGroupModel.fromJson);
  }

  @override
  Future<VendorContact> add({
    required VendorContactEdit edit,
    required String locale,
  }) => _written(
    () => _dio.post<dynamic>(
      ApiConstants.vendorContactsPath,
      data: _fields(edit),
      queryParameters: _localeQuery(locale),
    ),
    'contact',
  );

  @override
  Future<VendorContact> update({
    required int id,
    required VendorContactEdit edit,
    required String locale,
  }) => _written(
    () => _dio.put<dynamic>(
      ApiConstants.vendorContactPath(id),
      data: _fields(edit),
      queryParameters: _localeQuery(locale),
    ),
    'contact',
  );

  @override
  Future<void> remove({required int id, required String locale}) async {
    await _reply(
      () => _dio.delete<dynamic>(
        ApiConstants.vendorContactPath(id),
        queryParameters: _localeQuery(locale),
      ),
    );
  }

  @override
  Future<VendorContact> setPrimary({required int id, required String locale}) =>
      _written(
        () => _dio.post<dynamic>(
          ApiConstants.vendorContactPrimaryPath(id),
          queryParameters: _localeQuery(locale),
        ),
        'primary contact',
      );

  static Map<String, String> _fields(VendorContactEdit edit) =>
      <String, String>{'type': edit.type, 'value': edit.value};

  /// A write answers with the line it stored, so the page can show the id and
  /// the primary flag the server chose instead of guessing them.
  Future<VendorContact> _written(
    Future<Response<dynamic>> Function() request,
    String what,
  ) async {
    final body = await _reply(request);
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw ParseException('Contact reply carried no $what');
    }
    try {
      return VendorContactModel.fromJson(data);
    } on FormatException {
      throw ParseException('Contact reply carried no $what');
    }
  }

  /// A vendor with no contacts of a kind gets an empty list, not an error.
  Future<List<T>> _rows<T>(
    Map<String, dynamic>? body,
    String what,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final data = body?['data'];
    if (data == null) return const [];
    if (data is! List) {
      throw ParseException('Contact $what reply carried no list');
    }
    try {
      return data.whereType<Map<String, dynamic>>().map(parse).toList();
    } on FormatException {
      throw ParseException('Contact $what reply carried an unusable entry');
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
