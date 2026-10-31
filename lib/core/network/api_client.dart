import 'package:dio/dio.dart';

/// Central point for API configuration.
class ApiConstants {
  ApiConstants._();

  static const String overpassBaseUrl = 'https://overpass-api.de';
  static const String overpassPath = '/api/interpreter';

  static const String dalilBaseUrl = 'https://dalildimashq.com/api/v1';
  static const String randomCategoriesPath = '$dalilBaseUrl/categories/random';
  static const String categoriesPath = '$dalilBaseUrl/categories';

  /// Services published inside a category.
  static String categoryServicesPath(int categoryId) =>
      '$dalilBaseUrl/categories/$categoryId/services';

  static const String randomRegionsPath = '$dalilBaseUrl/regions/random';
  static const String regionsPath = '$dalilBaseUrl/regions';
  static const String bannersPath = '$dalilBaseUrl/banners';

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
