import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/category_page.dart';
import '../models/explore_category_model.dart';

abstract interface class CategoryRemoteDataSource {
  Future<List<ExploreCategoryModel>> fetchRandomCategories({
    required String locale,
  });

  Future<CategoryPage> fetchCategories({
    required String locale,
    required int page,
  });
}

/// Remote data source backed by the Dali Alsham categories API.
class DalilCategoryRemoteDataSource implements CategoryRemoteDataSource {
  DalilCategoryRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<ExploreCategoryModel>> fetchRandomCategories({
    required String locale,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.randomCategoriesPath,
        queryParameters: {'locale': locale},
      );
      return _parseItems(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<CategoryPage> fetchCategories({
    required String locale,
    required int page,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.categoriesPath,
        queryParameters: {'locale': locale, 'page': page},
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

      return CategoryPage(
        categories: _parseItems(body),
        hasMore: hasMore,
        nextPage: nextPage,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  List<ExploreCategoryModel> _parseItems(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected categories response');
    }
    final items = data['data'];
    if (items is! List) {
      throw const ParseException('Missing categories in response');
    }

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) ExploreCategoryModel.fromJson(item),
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
