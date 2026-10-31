import 'dart:convert';

import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/services/data/datasources/service_remote_datasource.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _CapturingAdapter implements HttpClientAdapter {
  _CapturingAdapter(this.payload);

  final Map<String, dynamic> payload;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _listingBody(Map<String, dynamic> service) => {
  'locale': 'ar',
  'count': 1,
  'pagination': {
    'current_page': 1,
    'per_page': 20,
    'total': 21,
    'last_page': 2,
    'has_more': true,
    'next_page': 2,
  },
  'data': [service],
};

void main() {
  test('requests the category services path with locale and page', () async {
    final adapter = _CapturingAdapter(_listingBody({'id': 1, 'name': 'Imran'}));
    final dataSource = DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    final page = await dataSource.fetchServices(
      scope: ServiceScope.category,
      scopeId: 1,
      locale: 'ar',
      page: 2,
    );

    expect(adapter.captured?.path, '${ApiConstants.categoriesPath}/1/services');
    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'page': 2});
    expect(page.hasMore, isTrue);
    expect(page.nextPage, 2);
  });

  test('requests the region services path', () async {
    final adapter = _CapturingAdapter(_listingBody({'id': 1, 'name': 'Imran'}));
    final dataSource = DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    await dataSource.fetchServices(
      scope: ServiceScope.region,
      scopeId: 7,
      locale: 'ar',
      page: 1,
    );

    expect(adapter.captured?.path, '${ApiConstants.regionsPath}/7/services');
  });

  test('adds distance sorting only when the location is known', () async {
    final withLocation = _CapturingAdapter(
      _listingBody({'id': 1, 'name': 'Imran'}),
    );
    await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = withLocation,
    ).fetchServices(
      scope: ServiceScope.region,
      scopeId: 1,
      locale: 'en',
      page: 1,
      userLat: 33.5050,
      userLng: 36.2850,
    );

    expect(withLocation.captured?.queryParameters, {
      'locale': 'en',
      'page': 1,
      'user_lat': 33.5050,
      'user_lng': 36.2850,
      'sort': 'distance',
    });

    final halfKnown = _CapturingAdapter(_listingBody({'id': 1, 'name': 'x'}));
    await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = halfKnown,
    ).fetchServices(
      scope: ServiceScope.category,
      scopeId: 1,
      locale: 'en',
      page: 1,
      userLat: 33.5050,
    );

    expect(halfKnown.captured?.queryParameters, {'locale': 'en', 'page': 1});
  });

  test('reads region, category and distance fields of a service', () async {
    final adapter = _CapturingAdapter(
      _listingBody(<String, dynamic>{
        'id': 2,
        'name': 'عمران',
        'slug': 'amran-1',
        'category': {'id': 1, 'name': 'مطاعم'},
        'region': {'id': 1, 'name': 'المزة'},
        'address': 'دمشق',
        'rating': 4.5,
        'reviews_count': 7,
        'distance_km': 0.4,
        'distance_text': '400 m',
        'is_favorited': false,
        'main_image':
            'http://127.0.0.1:8000/storage/join_requests/images/x.png',
      }),
    );

    final page =
        await DalilServiceRemoteDataSource(
          Dio()..httpClientAdapter = adapter,
        ).fetchServices(
          scope: ServiceScope.category,
          scopeId: 1,
          locale: 'ar',
          page: 1,
        );
    final service = page.services.single;

    expect(service.name, 'عمران');
    expect(service.regionName, 'المزة');
    expect(service.categoryName, 'مطاعم');
    expect(service.distanceText, '400 m');
    expect(service.rating, 4.5);
    expect(service.reviewsCount, 7);
    expect(
      service.imageUrl,
      'https://dalildimashq.com/storage/join_requests/images/x.png',
    );
  });

  test('a region listing shows the category of each service', () async {
    final adapter = _CapturingAdapter(
      _listingBody(<String, dynamic>{
        'id': 1,
        'name': 'الاسد',
        'category': {'id': 1, 'name': 'مطاعم'},
        'address': 'دمشق',
        'rating': 0,
        'reviews_count': 0,
        'main_image': null,
      }),
    );

    final page =
        await DalilServiceRemoteDataSource(
          Dio()..httpClientAdapter = adapter,
        ).fetchServices(
          scope: ServiceScope.region,
          scopeId: 1,
          locale: 'ar',
          page: 1,
        );
    final service = page.services.single;

    expect(service.categoryName, 'مطاعم');
    expect(service.regionName, isNull);
    expect(service.distanceText, isNull);
  });
}
