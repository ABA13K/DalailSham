import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../models/banner_ad_model.dart';

abstract interface class BannerRemoteDataSource {
  Future<List<BannerAdModel>> fetchBanners({required String locale});
}

/// Remote data source backed by the Dali Alsham banners API.
class DalilBannerRemoteDataSource implements BannerRemoteDataSource {
  DalilBannerRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<BannerAdModel>> fetchBanners({required String locale}) async {
    try {
      final response = await _dio.get<dynamic>(
        ApiConstants.bannersPath,
        queryParameters: {'locale': locale},
      );
      final body = response.data;
      if (body is! Map<String, dynamic>) {
        throw const ParseException('Unexpected banners response');
      }
      final items = body['data'];
      if (items is! List) {
        throw const ParseException('Missing banners in response');
      }

      return [
        for (final item in items)
          if (item is Map<String, dynamic>) BannerAdModel.fromJson(item),
      ];
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
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
