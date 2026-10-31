import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/category_service_page.dart';
import '../models/category_service_model.dart';

abstract interface class CategoryServiceRemoteDataSource {
  Future<CategoryServicePage> fetchServices({
    required int categoryId,
    required String locale,
    required int page,
    double? userLat,
    double? userLng,
  });
}

/// Remote data source backed by the Dali Alsham category services API.
class DalilCategoryServiceRemoteDataSource
    implements CategoryServiceRemoteDataSource {
  DalilCategoryServiceRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<CategoryServicePage> fetchServices({
    required int categoryId,
    required String locale,
    required int page,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.categoryServicesPath(categoryId),
        queryParameters: <String, dynamic>{
          'locale': locale,
          'page': page,
          if (userLat != null && userLng != null) ...{
            'user_lat': userLat,
            'user_lng': userLng,
            'sort': 'distance',
          },
        },
      );

      final body = response.data;
      final pagination = body is Map<String, dynamic>
          ? body['pagination']
          : null;
      final hasMore = pagination is Map<String, dynamic>
          ? pagination['has_more'] == true
          : false;
      final nextPage = pagination is Map<String, dynamic>
          ? (pagination['next_page'] as num?)?.toInt()
          : null;

      return CategoryServicePage(
        services: _parseItems(body),
        hasMore: hasMore,
        nextPage: nextPage,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  List<CategoryServiceModel> _parseItems(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected services response');
    }
    final items = data['data'];
    if (items is! List) {
      throw const ParseException('Missing services in response');
    }

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) CategoryServiceModel.fromJson(item),
    ];
  }

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
