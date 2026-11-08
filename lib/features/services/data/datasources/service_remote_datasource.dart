import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/service_page.dart';
import '../../domain/entities/service_scope.dart';
import '../../domain/entities/service_search_query.dart';
import '../models/service_summary_model.dart';

abstract interface class ServiceRemoteDataSource {
  Future<ServicePage> fetchServices({
    required ServiceScope scope,
    required String locale,
    required int page,
    bool authenticated,
    int? scopeId,
    double? userLat,
    double? userLng,
  });

  Future<ServicePage> search(ServiceSearchQuery query);
}

/// Remote data source backed by the Dali Alsham services listings.
class DalilServiceRemoteDataSource implements ServiceRemoteDataSource {
  DalilServiceRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<ServicePage> fetchServices({
    required ServiceScope scope,
    required String locale,
    required int page,
    bool authenticated = false,
    int? scopeId,
    double? userLat,
    double? userLng,
  }) async {
    try {
      final response = await _dio.get<dynamic>(
        _path(scope, scopeId, authenticated),
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
      return _page(
        body,
        // The favorites listing only contains favorited services, and its
        // items carry no `is_favorited` flag.
        _parseItems(body, favorited: scope == ServiceScope.favorites),
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  @override
  Future<ServicePage> search(ServiceSearchQuery query) async {
    try {
      final response = await _dio.get<dynamic>(
        query.authenticated
            ? ApiConstants.userServicesSearchPath
            : ApiConstants.servicesSearchPath,
        queryParameters: _searchParams(query),
      );

      final body = response.data;
      return _page(body, _parseItems(body));
    } on DioException catch (error) {
      throw _mapDioException(error);
    }
  }

  /// The search sends only the filters that were chosen; a rating of `0` is a
  /// choice and travels, an absent sort does not.
  static Map<String, dynamic> _searchParams(ServiceSearchQuery query) {
    final sort = query.sort;
    return <String, dynamic>{
      'q': query.text,
      'locale': query.locale,
      'page': query.page,
      if (query.userLat != null && query.userLng != null) ...{
        'user_lat': query.userLat,
        'user_lng': query.userLng,
      },
      if (query.categoryId != null) 'category_id': query.categoryId,
      if (query.regionId != null) 'region_id': query.regionId,
      if (sort != null) 'sort': sort.wire,
      if (query.minRating != null) 'min_rating': query.minRating,
    };
  }

  static String _path(ServiceScope scope, int? scopeId, bool authenticated) =>
      switch (scope) {
        ServiceScope.favorites => ApiConstants.favoritesServicesPath,
        ServiceScope.topRated =>
          authenticated
              ? ApiConstants.userTopRatedServicesPath
              : ApiConstants.topRatedServicesPath,
        ServiceScope.nearby =>
          authenticated
              ? ApiConstants.userNearbyServicesPath
              : ApiConstants.nearbyServicesPath,
        ServiceScope.category =>
          '${ApiConstants.categoriesPath}/$scopeId/services',
        ServiceScope.region => '${ApiConstants.regionsPath}/$scopeId/services',
      };

  /// Every listing answers with the same envelope: the rows in `data`, the page
  /// that follows them in `pagination` and, for the nearby listing, the `mode`
  /// that picked them.
  ServicePage _page(Object? body, List<ServiceSummaryModel> services) {
    final listing = body is Map<String, dynamic> ? body : const {};
    final pagination = listing['pagination'];
    final mode = listing['mode'];
    return ServicePage(
      services: services,
      hasMore: pagination is Map<String, dynamic>
          ? pagination['has_more'] == true
          : false,
      nextPage: pagination is Map<String, dynamic>
          ? (pagination['next_page'] as num?)?.toInt()
          : null,
      mode: ServiceListingMode.fromWire(mode is String ? mode : null),
    );
  }

  List<ServiceSummaryModel> _parseItems(
    Object? data, {
    bool favorited = false,
  }) {
    if (data is! Map<String, dynamic>) {
      throw const ParseException('Unexpected services response');
    }
    final items = data['data'];
    if (items is! List) {
      throw const ParseException('Missing services in response');
    }

    return [
      for (final item in items)
        if (item is Map<String, dynamic>)
          ServiceSummaryModel.fromJson(
            favorited ? {...item, 'is_favorited': true} : item,
          ),
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
