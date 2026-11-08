import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/auth_user_model.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/entities/avatar_file.dart';
import '../../../auth/domain/entities/password_change.dart';
import '../../domain/entities/profile_edit.dart';

abstract interface class ProfileRemoteDataSource {
  /// `GET /user/profile`
  Future<AuthUser> profile(String locale);

  /// `PUT /user/profile`
  Future<AuthUser> update({required ProfileEdit edit, required String locale});

  /// `POST /user/profile/avatar` — answers with the address of the new picture.
  Future<String> uploadAvatar({
    required AvatarFile file,
    required String locale,
  });

  /// `DELETE /user/profile/avatar`
  Future<void> removeAvatar();

  /// `POST /user/profile/change-password`
  Future<void> changePassword(PasswordChange change);

  /// `DELETE /user/profile/account`
  Future<void> deleteAccount(String password);
}

/// Remote data source backed by the Dali Alsham profile endpoints.
///
/// All six are authenticated: the shared Dio carries the bearer token through
/// `AuthInterceptor`.
class DalilProfileRemoteDataSource implements ProfileRemoteDataSource {
  DalilProfileRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<AuthUser> profile(String locale) => _user(
    _dio.get<dynamic>(
      ApiConstants.profilePath,
      queryParameters: _localeQuery(locale),
    ),
  );

  @override
  Future<AuthUser> update({
    required ProfileEdit edit,
    required String locale,
  }) => _user(
    _dio.put<dynamic>(
      ApiConstants.profilePath,
      data: <String, dynamic>{
        'full_name': edit.fullName,
        'address': edit.address,
        if (edit.gender != null) 'gender': edit.gender!.wire,
      },
      queryParameters: _localeQuery(locale),
    ),
  );

  @override
  Future<String> uploadAvatar({
    required AvatarFile file,
    required String locale,
  }) async {
    final body = await _reply(
      () => _dio.post<dynamic>(
        ApiConstants.profileAvatarPath,
        data: FormData.fromMap(<String, dynamic>{
          'avatar': MultipartFile.fromBytes(
            file.bytes,
            filename: file.fileName,
          ),
        }),
        queryParameters: _localeQuery(locale),
      ),
    );
    final data = body?['data'];
    final avatar = data is Map<String, dynamic> ? data['avatar'] : null;
    if (avatar is! String || avatar.trim().isEmpty) {
      throw const ParseException('Avatar reply carried no address');
    }
    return avatar.trim();
  }

  @override
  Future<void> removeAvatar() => _reply(
    () => _dio.delete<dynamic>(ApiConstants.profileAvatarPath),
    // 404 says there was no picture to delete, which is where the caller
    // wanted the account to be.
    absentIsDone: true,
  );

  @override
  Future<void> changePassword(PasswordChange change) async {
    await _reply(
      () => _dio.post<dynamic>(
        ApiConstants.profilePasswordPath,
        data: <String, dynamic>{
          'current_password': change.currentPassword,
          'password': change.password,
          'password_confirmation': change.confirmation,
        },
      ),
    );
  }

  @override
  Future<void> deleteAccount(String password) async {
    await _reply(
      () => _dio.delete<dynamic>(
        ApiConstants.profileAccountPath,
        data: <String, dynamic>{'password': password},
      ),
    );
  }

  Future<AuthUser> _user(Future<Response<dynamic>> response) async {
    final body = await _reply(() => response);
    final data = body?['data'];
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Profile reply carried no account');
    }
    try {
      return AuthUserModel.fromJson(data);
    } on FormatException {
      throw const ParseException('Profile reply carried no account');
    }
  }

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
