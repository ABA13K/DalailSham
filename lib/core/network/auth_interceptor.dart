import 'package:dio/dio.dart';

import '../settings/domain/token_repository.dart';

/// Adds `Authorization: Bearer <token>` to requests whenever a token is stored.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._tokenRepository);

  final TokenRepository _tokenRepository;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenRepository.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}
