import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/favorite_mutation.dart';

abstract interface class FavoritesRemoteDataSource {
  /// `POST /favorites/services/{slug}`
  Future<FavoriteMutation> favorite(String slug);

  /// `DELETE /favorites/services/{slug}`
  Future<FavoriteMutation> unfavorite(String slug);
}

/// Remote data source backed by the Dali Alsham favorites endpoints.
///
/// Both calls are authenticated: the shared Dio carries the bearer token
/// through `AuthInterceptor`.
class DalilFavoritesRemoteDataSource implements FavoritesRemoteDataSource {
  DalilFavoritesRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<FavoriteMutation> favorite(String slug) async {
    try {
      return await _mutation(_dio.post<dynamic>(_path(slug)));
    } on DioException catch (error) {
      // 409 means the service is already a favorite, which is where the caller
      // wanted it to be.
      if (error.response?.statusCode == 409) {
        return FavoriteMutation(
          isFavorited: true,
          message: _message(_body(error.response)),
        );
      }
      throw _mapDioException(error);
    }
  }

  @override
  Future<FavoriteMutation> unfavorite(String slug) async {
    try {
      return await _mutation(_dio.delete<dynamic>(_path(slug)));
    } on DioException catch (error) {
      // 404 means it was not a favorite to begin with. A 404 from POST is a
      // different case — an unapproved account — and stays an error.
      if (error.response?.statusCode == 404) {
        return FavoriteMutation(
          isFavorited: false,
          message: _message(_body(error.response)),
        );
      }
      throw _mapDioException(error);
    }
  }

  Future<FavoriteMutation> _mutation(Future<Response<dynamic>> response) async {
    final body = _body(await response);
    final payload = body?['data'];
    return FavoriteMutation(
      isFavorited:
          payload is Map<String, dynamic> && payload['is_favorited'] == true,
      message: _message(body),
    );
  }

  static String _path(String slug) =>
      '${ApiConstants.favoritesServicesPath}/$slug';

  static Map<String, dynamic>? _body(Response<dynamic>? response) =>
      response?.data is Map<String, dynamic>
      ? response!.data as Map<String, dynamic>
      : null;

  static String _message(Map<String, dynamic>? body) =>
      (body?['message'] as String?)?.trim() ?? '';

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
