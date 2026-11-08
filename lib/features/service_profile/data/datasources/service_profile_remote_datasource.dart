import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/entities/service_product.dart';
import '../../domain/entities/service_review.dart';
import '../models/service_detail_model.dart';
import '../models/service_product_model.dart';
import '../models/service_review_model.dart';

abstract interface class ServiceProfileRemoteDataSource {
  Future<ServiceDetail> fetchDetail({
    required String slug,
    required String locale,
    bool authenticated,
    double? userLat,
    double? userLng,
  });

  Future<List<String>> fetchImages({required String slug});

  Future<ServiceProductPage> fetchProducts({
    required String slug,
    required String locale,
    required int page,
    String? categorySlug,
  });

  Future<List<ServiceProductCategory>> fetchProductCategories({
    required String slug,
    required String locale,
  });

  Future<ServiceReviewPage> fetchReviews({
    required String slug,
    required String locale,
    required int page,
    required ServiceReviewSort sort,
    bool authenticated,
  });
}

/// Remote data source backed by the Dali Alsham service profile endpoints.
class DalilServiceProfileRemoteDataSource
    implements ServiceProfileRemoteDataSource {
  DalilServiceProfileRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ServiceDetail> fetchDetail({
    required String slug,
    required String locale,
    bool authenticated = false,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        authenticated
            ? ApiConstants.userServiceDetailPath(slug)
            : ApiConstants.serviceDetailPath(slug),
        queryParameters: <String, dynamic>{
          'locale': locale,
          if (userLat != null && userLng != null) ...{
            'user_lat': userLat,
            'user_lng': userLng,
            'sort': 'distance',
          },
        },
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ParseException('Unexpected service response');
      }
      return ServiceDetailModel.fromEnvelope(body);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<List<String>> fetchImages({required String slug}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.serviceImagesPath(slug),
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ParseException('Unexpected images response');
      }
      final data = body['data'];
      if (data is! List) {
        throw const ParseException('Missing images in response');
      }
      return [
        for (final image in data)
          if (image is String && image.trim().isNotEmpty) image.trim(),
      ];
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<ServiceProductPage> fetchProducts({
    required String slug,
    required String locale,
    required int page,
    String? categorySlug,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        categorySlug == null
            ? ApiConstants.serviceProductsPath(slug)
            : ApiConstants.serviceCategoryProductsPath(slug, categorySlug),
        queryParameters: <String, dynamic>{'locale': locale, 'page': page},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ParseException('Unexpected products response');
      }
      final pagination = _pagination(body);
      return ServiceProductPage(
        products: _products(body),
        hasMore: pagination.hasMore,
        nextPage: pagination.nextPage,
        total: pagination.total,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<List<ServiceProductCategory>> fetchProductCategories({
    required String slug,
    required String locale,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.serviceProductCategoriesPath(slug),
        queryParameters: <String, dynamic>{'locale': locale},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ParseException('Unexpected categories response');
      }
      final data = body['data'];
      if (data is! List) {
        throw const ParseException('Missing categories in response');
      }
      return [
        for (final category in data)
          if (category is Map<String, dynamic> &&
              category['slug'] is String &&
              category['name'] is String)
            ServiceProductCategory(
              slug: (category['slug'] as String).trim(),
              name: (category['name'] as String).trim(),
              productsCount: (category['products_count'] as num?)?.toInt() ?? 0,
            ),
      ];
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<ServiceReviewPage> fetchReviews({
    required String slug,
    required String locale,
    required int page,
    required ServiceReviewSort sort,
    bool authenticated = false,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        authenticated
            ? ApiConstants.userServiceReviewsPath(slug)
            : ApiConstants.serviceReviewsPath(slug),
        queryParameters: <String, dynamic>{
          'locale': locale,
          'page': page,
          'sort': sort.wire,
        },
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ParseException('Unexpected reviews response');
      }
      final pagination = _pagination(body);
      final summary = body['summary'];
      final breakdown = summary is Map<String, dynamic>
          ? summary['rating_breakdown']
          : null;
      return ServiceReviewPage(
        reviews: [
          for (final review in _list(body['data']))
            if (review is Map<String, dynamic>)
              ServiceReviewModel.fromJson(review),
        ],
        hasMore: pagination.hasMore,
        nextPage: pagination.nextPage,
        summary: ServiceReviewSummary(
          averageRating: summary is Map<String, dynamic>
              ? (summary['average_rating'] as num?)?.toDouble() ?? 0
              : 0,
          totalReviews: summary is Map<String, dynamic>
              ? (summary['total_reviews'] as num?)?.toInt() ?? 0
              : 0,
          breakdown: {
            for (var stars = 1; stars <= 5; stars++)
              stars: breakdown is Map<String, dynamic>
                  ? (breakdown['$stars'] as num?)?.toInt() ?? 0
                  : 0,
          },
        ),
        sort: ServiceReviewSort.fromWire(
          body['sort'] is String ? body['sort'] as String : null,
        ),
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  static List<ServiceProduct> _products(Map<String, dynamic> body) {
    final data = body['data'];
    if (data is! List) {
      throw const ParseException('Missing products in response');
    }
    return [
      for (final product in data)
        if (product is Map<String, dynamic>)
          ServiceProductModel.fromJson(product),
    ];
  }

  static ({bool hasMore, int? nextPage, int total}) _pagination(
    Map<String, dynamic> body,
  ) {
    final pagination = body['pagination'];
    if (pagination is! Map<String, dynamic>) {
      return (hasMore: false, nextPage: null, total: 0);
    }
    return (
      hasMore: pagination['has_more'] == true,
      nextPage: (pagination['next_page'] as num?)?.toInt(),
      total: (pagination['total'] as num?)?.toInt() ?? 0,
    );
  }

  static List<dynamic> _list(Object? value) => value is List ? value : const [];

  AppException _mapDioException(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => const TimeoutException(),
      DioExceptionType.connectionError => const NetworkException(),
      DioExceptionType.badResponse => ServerException(
        'HTTP ${error.response?.statusCode}',
      ),
      _ => ServerException(error.message ?? 'Request failed'),
    };
  }
}