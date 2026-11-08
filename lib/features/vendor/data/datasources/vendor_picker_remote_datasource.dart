import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../categories/data/models/explore_category_model.dart';
import '../../../categories/domain/entities/explore_category.dart';
import '../../../regions/data/models/region_model.dart';
import '../../../regions/domain/entities/region.dart';

/// The two pick lists the join-request form searches before an account exists.
abstract interface class VendorPickerRemoteDataSource {
  /// `GET /vendor/regions` — [query] is matched against the region name.
  Future<List<Region>> regions({required String locale, String? query});

  /// `GET /vendor/categories` — [query] is matched against the category name.
  Future<List<ExploreCategory>> categories({
    required String locale,
    String? query,
  });
}

/// Remote data source backed by the Dali Alsham vendor pick lists.
///
/// Both are public — the form is filled by someone who has no token yet.
class DalilVendorPickerRemoteDataSource
    implements VendorPickerRemoteDataSource {
  DalilVendorPickerRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<Region>> regions({required String locale, String? query}) =>
      _list(
        () => _dio.get<dynamic>(
          ApiConstants.vendorRegionsPath,
          queryParameters: _query(locale, query),
        ),
        RegionModel.fromJson,
      );

  @override
  Future<List<ExploreCategory>> categories({
    required String locale,
    String? query,
  }) => _list(
    () => _dio.get<dynamic>(
      ApiConstants.vendorCategoriesPath,
      queryParameters: _query(locale, query),
    ),
    ExploreCategoryModel.fromJson,
  );

  /// A search that matches nothing is an empty list, not an error — the reply
  /// still says `تم بنجاح` with `data: []`.
  Future<List<T>> _list<T>(
    Future<Response<dynamic>> Function() request,
    T Function(Map<String, dynamic>) parse,
  ) async {
    final body = await _reply(request);
    final data = body?['data'];
    if (data == null) return const [];
    if (data is! List) {
      throw const ParseException('Pick list reply carried no list');
    }
    try {
      return data.whereType<Map<String, dynamic>>().map(parse).toList();
    } on FormatException {
      throw const ParseException('Pick list reply carried an unusable entry');
    }
  }

  Future<Map<String, dynamic>?> _reply(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return _body(await request());
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  static Map<String, String> _query(String locale, String? query) {
    final text = query?.trim();
    return <String, String>{
      'locale': locale,
      if (text != null && text.isNotEmpty) 'q': text,
    };
  }

  static Map<String, dynamic>? _body(Response<dynamic>? response) =>
      response?.data is Map<String, dynamic>
      ? response!.data as Map<String, dynamic>
      : null;

  static String _message(Map<String, dynamic>? body) {
    final errors = body?['errors'];
    if (errors is Map) {
      for (final messages in errors.values) {
        final first = messages is List && messages.isNotEmpty
            ? messages.first
            : null;
        if (first is String && first.trim().isNotEmpty) return first.trim();
      }
    }
    return (body?['message'] as String?)?.trim() ?? '';
  }

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
