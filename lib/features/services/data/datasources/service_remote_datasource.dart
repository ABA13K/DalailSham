import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/service_page.dart';
import '../../domain/entities/service_scope.dart';
import '../models/service_summary_model.dart';

abstract interface class ServiceRemoteDataSource {
  Future<ServicePage> fetchServices({
    required ServiceScope scope,
    required int scopeId,
    required String locale,
    required int page,
    double? userLat,
    double? userLng,
  });
}

/// Remote data source backed by the Dali Alsham services listings.
class DalilServiceRemoteDataSource implements ServiceRemoteDataSource {
  DalilServiceRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ServicePage> fetchServices({
    required ServiceScope scope,
    required int scopeId,
    required String locale,
    required int page,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(scope, scopeId),
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

      return ServicePage(
        services: _parseItems(body),
        hasMore: hasMore,
        nextPage: nextPage,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  static String _path(ServiceScope scope, int scopeId) => switch (scope) {
    ServiceScope.category => '${ApiConstants.categoriesPath}/$scopeId/services',
    ServiceScope.region => '${ApiConstants.regionsPath}/$scopeId/services',
  };

  List<ServiceSummaryModel> _parseItems(Object? data) {
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected services response');
    }
    final items = data['data'];
    if (items is! List) {
      throw const ParseException('Missing services in response');
    }

    return [
      for (final item in items)
        if (item is Map<String, dynamic>) ServiceSummaryModel.fromJson(item),
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
