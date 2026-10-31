import 'dart:convert';

import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/services/data/datasources/category_service_remote_datasource.dart';
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

void main() {
  final body = <String, dynamic>{
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
    'data': <Map<String, dynamic>>[
      {
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
      },
    ],
  };

  test('requests the category services path with locale and page', () async {
    final adapter = _CapturingAdapter(body);
    final dio = Dio()..httpClientAdapter = adapter;
    final dataSource = DalilCategoryServiceRemoteDataSource(dio);

    final page = await dataSource.fetchServices(
      categoryId: 1,
      locale: 'ar',
      page: 2,
    );

    expect(adapter.captured?.path, ApiConstants.categoryServicesPath(1));
    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'page': 2});
    expect(page.hasMore, isTrue);
    expect(page.nextPage, 2);
    expect(page.services.single.regionName, 'المزة');
    expect(page.services.single.distanceText, '400 m');
  });

  test('adds distance sorting only when the location is known', () async {
    final withLocation = _CapturingAdapter(body);
    await DalilCategoryServiceRemoteDataSource(
      Dio()..httpClientAdapter = withLocation,
    ).fetchServices(
      categoryId: 1,
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

    final halfKnown = _CapturingAdapter(body);
    await DalilCategoryServiceRemoteDataSource(
      Dio()..httpClientAdapter = halfKnown,
    ).fetchServices(categoryId: 1, locale: 'en', page: 1, userLat: 33.5050);

    expect(halfKnown.captured?.queryParameters, {'locale': 'en', 'page': 1});
  });

  test('rewrites localhost image origins and reads rating fields', () async {
    final adapter = _CapturingAdapter(body);
    final dataSource = DalilCategoryServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    final page = await dataSource.fetchServices(
      categoryId: 1,
      locale: 'ar',
      page: 1,
    );
    final service = page.services.single;

    expect(service.id, 2);
    expect(service.name, 'عمران');
    expect(
      service.imageUrl,
      'https://dalildimashq.com/storage/join_requests/images/x.png',
    );
    expect(service.rating, 4.5);
    expect(service.reviewsCount, 7);
  });
}
