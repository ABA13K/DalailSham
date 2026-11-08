import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/region_page.dart';
import '../models/region_model.dart';

abstract interface class RegionRemoteDataSource {
  Future<List<RegionModel>> fetchRandomRegions({required String locale});

  Future<RegionPage> fetchRegions({required String locale, required int page});
}

/// Remote data source backed by the Dali Alsham regions API.
class DalilRegionRemoteDataSource implements RegionRemoteDataSource {
  DalilRegionRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<RegionModel>> fetchRandomRegions({required String locale}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.randomRegionsPath,
        queryParameters: {'locale': locale},
      );
      return _parseItems(response.data);
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<RegionPage> fetchRegions({
    required String locale,
    required int page,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.regionsPath,
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

      return RegionPage(
        regions: _parseItems(body),
        hasMore: hasMore,
        nextPage: nextPage,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  List<RegionModel> _parseItems(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected regions response');
    }
    final items = data['data'];
    if (items is! List) {
      throw const ParseException('Missing regions in response');
    }

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) RegionModel.fromJson(item),
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
