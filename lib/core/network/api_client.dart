import 'package:dio/dio.dart';

/// Central point for API configuration.
class ApiConstants {
  ApiConstants._();

  static const String overpassBaseUrl = 'https://overpass-api.de';
  static const String overpassPath = '/api/interpreter';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const String userAgent = 'DaliAlsham/1.0';
}

/// Creates the shared [Dio] instance used by all remote data sources.
Dio createDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.overpassBaseUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      headers: {'User-Agent': ApiConstants.userAgent},
      responseType: ResponseType.json,
    ),
  );
  return dio;
}
