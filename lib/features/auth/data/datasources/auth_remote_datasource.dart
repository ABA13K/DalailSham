import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/entities/join_request.dart';
import '../../domain/entities/registration.dart';
import '../models/auth_user_model.dart';

abstract interface class AuthRemoteDataSource {
  /// `POST /auth/login`
  Future<AuthSession> login(Credentials credentials);

  /// `POST /auth/register`
  Future<AuthSession> register(Registration registration);

  /// `POST /vendor/join-request`
  Future<AuthSession> joinRequest(JoinRequest request);
}

/// Remote data source backed by the Dali Alsham auth endpoints.
///
/// All three are public: the bearer token the shared Dio may carry is only what
/// the response hands back for the next calls.
class DalilAuthRemoteDataSource implements AuthRemoteDataSource {
  DalilAuthRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AuthSession> login(Credentials credentials) => _session(
    _dio.post<dynamic>(
      ApiConstants.authLoginPath,
      data: <String, dynamic>{
        'login': credentials.login,
        'password': credentials.password,
      },
    ),
  );

  @override
  Future<AuthSession> register(Registration registration) => _session(
    _dio.post<dynamic>(
      ApiConstants.authRegisterPath,
      data: <String, dynamic>{
        'full_name': registration.fullName,
        'email': registration.email,
        'mobile': registration.mobile,
        'password': registration.password,
        'password_confirmation': registration.password,
        'gender': registration.gender.wire,
        'address': registration.address,
        'avatar': null,
        'locale': registration.locale,
      },
    ),
  );

  @override
  Future<AuthSession> joinRequest(JoinRequest request) => _session(
    _dio.post<dynamic>(
      ApiConstants.vendorJoinRequestPath,
      data: _form(request),
    ),
    // The application reply wraps the account next to the request it created.
    accountKey: 'user',
  );

  /// Multipart because the cover photo rides along with the text fields; the
  /// optional ones are left out entirely rather than sent empty, so a nullable
  /// rule is not handed a value it would have to reject.
  static FormData _form(JoinRequest request) {
    final image = request.mainImage;
    return FormData.fromMap(<String, dynamic>{
      ..._textFields(request),
      if (image != null)
        'main_image': MultipartFile.fromBytes(
          image.bytes,
          filename: image.fileName,
        ),
    });
  }

  static Map<String, dynamic> _textFields(
    JoinRequest request,
  ) => <String, dynamic>{
    'full_name': request.fullName,
    'mobile': request.mobile,
    'password': request.password,
    'password_confirmation': request.password,
    'gender': request.gender.wire,
    'region_id': request.regionId,
    'category_id': request.categoryId,
    'name_ar': request.nameAr,
    'name_en': request.nameEn,
    'subscription_type': JoinRequest.subscriptionType,
    if (request.email != null) 'email': request.email,
    if (request.phone != null) 'phone': request.phone,
    if (request.companyEmail != null) 'company_email': request.companyEmail,
    if (request.addressAr != null) 'address_ar': request.addressAr,
    if (request.addressEn != null) 'address_en': request.addressEn,
    if (request.descriptionAr != null) 'description_ar': request.descriptionAr,
    if (request.descriptionEn != null) 'description_en': request.descriptionEn,
  };

  Future<AuthSession> _session(
    Future<Response<dynamic>> response, {
    String? accountKey,
  }) async {
    final Map<String, dynamic>? body;
    try {
      body = _body(await response);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }

    final token = (body?['token'] as String?)?.trim();
    final data = body?['data'];
    final account = accountKey == null || data is! Map<String, dynamic>
        ? data
        : data[accountKey];
    if (token == null || token.isEmpty || account is! Map<String, dynamic>) {
      throw const ParseException('Account payload carried no token');
    }

    try {
      return AuthSession(user: AuthUserModel.fromJson(account), token: token);
    } on FormatException {
      throw const ParseException('Account payload carried no account');
    }
  }

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
