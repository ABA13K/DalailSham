import 'dart:convert';

import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/services/data/datasources/service_remote_datasource.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_search_query.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/entities/service_sort.dart';
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

/// The top-ten listing returns the same items without a `pagination` block.
Map<String, dynamic> _topTenBody(Map<String, dynamic> service) => {
  'locale': 'ar',
  'user_location': {'lat': 33.5, 'lng': 36.28},
  'is_authenticated': false,
  'count': 1,
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
    expect(service.slug, 'amran-1');
    expect(service.isFavorited, isFalse);
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

  test('requests the favorites path without an id', () async {
    final adapter = _CapturingAdapter(_listingBody({'id': 1, 'name': 'Imran'}));

    await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).fetchServices(scope: ServiceScope.favorites, locale: 'ar', page: 1);

    expect(adapter.captured?.path, ApiConstants.favoritesServicesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'page': 1});
  });

  test('treats every favorites item as favorited', () async {
    final adapter = _CapturingAdapter(
      _listingBody(<String, dynamic>{
        'id': 2,
        'name': 'عمران',
        'slug': 'amran-1',
        'category': {'id': 1, 'name': 'مطاعم'},
        'region': {'id': 1, 'name': 'المزة'},
      }),
    );

    final page = await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).fetchServices(scope: ServiceScope.favorites, locale: 'ar', page: 1);

    expect(page.services.single.isFavorited, isTrue);
    expect(page.services.single.slug, 'amran-1');
  });

  test('requests the public top-ten path', () async {
    final adapter = _CapturingAdapter(_topTenBody({'id': 1, 'name': 'Imran'}));

    await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).fetchServices(scope: ServiceScope.topRated, locale: 'ar', page: 1);

    expect(adapter.captured?.path, ApiConstants.topRatedServicesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'page': 1});
  });

  test('requests the signed-in top-ten path with the user location', () async {
    final adapter = _CapturingAdapter(_topTenBody({'id': 1, 'name': 'Imran'}));

    await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).fetchServices(
      scope: ServiceScope.topRated,
      locale: 'ar',
      page: 1,
      authenticated: true,
      userLat: 33.5,
      userLng: 36.28,
    );

    expect(adapter.captured?.path, ApiConstants.userTopRatedServicesPath);
    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'page': 1,
      'user_lat': 33.5,
      'user_lng': 36.28,
      'sort': 'distance',
    });
  });

  test('reads the top-ten fields of an unpaged response', () async {
    final adapter = _CapturingAdapter(
      _topTenBody(<String, dynamic>{
        'id': 2,
        'name': 'عمران',
        'slug': 'amran-1',
        'category': {'id': 1, 'name': 'مطاعم'},
        'region': {'id': 1, 'name': 'المزة'},
        'address': 'دمشق',
        'rating': 4.9,
        'reviews_count': 12,
        'distance_km': 0.4,
        'distance_text': '400 m',
        'is_favorited': true,
        'main_image': 'http://127.0.0.1:8000/storage/services/x.png',
      }),
    );

    final page = await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).fetchServices(scope: ServiceScope.topRated, locale: 'ar', page: 1);
    final service = page.services.single;

    expect(page.hasMore, isFalse);
    expect(page.nextPage, isNull);
    expect(service.rating, 4.9);
    expect(service.reviewsCount, 12);
    expect(service.isFavorited, isTrue);
    expect(service.regionName, 'المزة');
    expect(service.categoryName, 'مطاعم');
    expect(service.imageUrl, 'https://dalildimashq.com/storage/services/x.png');
  });

  test('asks the public search with the words and the language', () async {
    final adapter = _CapturingAdapter(
      _listingBody(<String, dynamic>{
        'id': 1,
        'name': 'الاسد',
        'category': {'id': 1, 'name': 'مطاعم'},
        'region': {'id': 1, 'name': 'المزة'},
        'address': 'دمشق',
        'rating': 0,
        'reviews_count': 0,
        'distance_km': null,
        'distance_text': null,
        'is_favorited': false,
        'main_image': null,
      }),
    );

    final page = await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).search(const ServiceSearchQuery(text: 'الاسد', locale: 'ar'));

    expect(adapter.captured?.path, ApiConstants.servicesSearchPath);
    expect(adapter.captured?.queryParameters, {
      'q': 'الاسد',
      'locale': 'ar',
      'page': 1,
    });
    expect(page.services.single.name, 'الاسد');
    expect(page.services.single.isFavorited, isFalse);
    expect(page.services.single.distanceText, isNull);
  });

  test('asks the signed-in search, which knows the favorites', () async {
    final adapter = _CapturingAdapter(
      _listingBody(<String, dynamic>{
        'id': 1,
        'name': 'الاسد',
        'is_favorited': true,
      }),
    );

    final page =
        await DalilServiceRemoteDataSource(
          Dio()..httpClientAdapter = adapter,
        ).search(
          const ServiceSearchQuery(
            text: 'الاسد',
            locale: 'ar',
            authenticated: true,
          ),
        );

    expect(adapter.captured?.path, ApiConstants.userServicesSearchPath);
    expect(page.services.single.isFavorited, isTrue);
  });

  test(
    'sends the location the user allowed without deciding the order',
    () async {
      final adapter = _CapturingAdapter(
        _listingBody({'id': 1, 'name': 'الاسد'}),
      );

      await DalilServiceRemoteDataSource(
        Dio()..httpClientAdapter = adapter,
      ).search(
        const ServiceSearchQuery(
          text: 'الاسد',
          locale: 'ar',
          userLat: 33.5,
          userLng: 36.28,
        ),
      );

      expect(adapter.captured?.queryParameters, {
        'q': 'الاسد',
        'locale': 'ar',
        'page': 1,
        'user_lat': 33.5,
        'user_lng': 36.28,
      });
    },
  );

  test(
    'sends every filter that was chosen, the zero rating included',
    () async {
      final adapter = _CapturingAdapter(
        _listingBody({'id': 1, 'name': 'الاسد'}),
      );

      await DalilServiceRemoteDataSource(
        Dio()..httpClientAdapter = adapter,
      ).search(
        const ServiceSearchQuery(
          text: 'الاسد',
          locale: 'ar',
          page: 2,
          categoryId: 1,
          regionId: 1,
          sort: ServiceSort.rating,
          minRating: 0,
        ),
      );

      expect(adapter.captured?.queryParameters, {
        'q': 'الاسد',
        'locale': 'ar',
        'page': 2,
        'category_id': 1,
        'region_id': 1,
        'sort': 'rating',
        'min_rating': 0,
      });
    },
  );

  test('sends nothing the vendor left alone', () async {
    final adapter = _CapturingAdapter(_listingBody({'id': 1, 'name': 'الاسد'}));

    await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).search(
      const ServiceSearchQuery(
        text: 'الاسد',
        locale: 'ar',
        sort: ServiceSort.distance,
      ),
    );

    expect(adapter.captured?.queryParameters, {
      'q': 'الاسد',
      'locale': 'ar',
      'page': 1,
      'sort': 'distance',
    });
  });

  test(
    'a search that matched nothing is an empty page, not an error',
    () async {
      final adapter = _CapturingAdapter(<String, dynamic>{
        'query': 'لا شيء',
        'count': 0,
        'pagination': {'has_more': false, 'next_page': null},
        'data': <dynamic>[],
      });

      final page = await DalilServiceRemoteDataSource(
        Dio()..httpClientAdapter = adapter,
      ).search(const ServiceSearchQuery(text: 'لا شيء', locale: 'ar'));

      expect(page.services, isEmpty);
      expect(page.hasMore, isFalse);
    },
  );

  // ---- the ten nearest services ----

  /// The listing answers with a `mode` and, only when it could sort around a
  /// location, with the pagination block that goes with it.
  Map<String, dynamic> nearbyBody({
    required String mode,
    required Map<String, dynamic> service,
    bool paged = false,
  }) => {
    'locale': 'ar',
    'mode': mode,
    if (mode == 'nearby') 'user_location': {'lat': 33.5, 'lng': 36.28},
    'is_authenticated': false,
    'count': 1,
    if (paged)
      'pagination': {'current_page': 1, 'has_more': true, 'next_page': 2},
    'data': [service],
  };

  test('requests the public nearby path with the location', () async {
    final adapter = _CapturingAdapter(
      nearbyBody(
        mode: 'nearby',
        service: {'id': 1, 'name': 'Imran'},
        paged: true,
      ),
    );

    final page =
        await DalilServiceRemoteDataSource(
          Dio()..httpClientAdapter = adapter,
        ).fetchServices(
          scope: ServiceScope.nearby,
          locale: 'ar',
          page: 1,
          userLat: 33.5,
          userLng: 36.28,
        );

    expect(adapter.captured?.path, ApiConstants.nearbyServicesPath);
    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'page': 1,
      'user_lat': 33.5,
      'user_lng': 36.28,
      'sort': 'distance',
    });
    expect(page.mode, ServiceListingMode.nearby);
    expect(page.hasMore, isTrue);
    expect(page.nextPage, 2);
  });

  test('requests the signed-in nearby path', () async {
    final adapter = _CapturingAdapter(
      nearbyBody(mode: 'nearby', service: {'id': 1, 'name': 'Imran'}),
    );

    await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).fetchServices(
      scope: ServiceScope.nearby,
      locale: 'ar',
      page: 1,
      authenticated: true,
      userLat: 33.5,
      userLng: 36.28,
    );

    expect(adapter.captured?.path, ApiConstants.userNearbyServicesPath);
  });

  test('a nearby listing without a location is the random one', () async {
    final adapter = _CapturingAdapter(
      nearbyBody(mode: 'random', service: {'id': 1, 'name': 'Imran'}),
    );

    final page = await DalilServiceRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    ).fetchServices(scope: ServiceScope.nearby, locale: 'ar', page: 1);

    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'page': 1});
    expect(page.mode, ServiceListingMode.random);
    expect(page.hasMore, isFalse);
    expect(page.services.single.distanceText, isNull);
  });

  test('reads the distance of a service sorted around the user', () async {
    final adapter = _CapturingAdapter(
      nearbyBody(
        mode: 'nearby',
        service: <String, dynamic>{
          'id': 2,
          'name': 'عمران',
          'slug': 'amran-1',
          'category': {'id': 1, 'name': 'مطاعم'},
          'region': {'id': 1, 'name': 'المزة'},
          'rating': 0,
          'reviews_count': 0,
          'distance_km': 0,
          'distance_text': '0 m',
          'is_favorited': false,
          'main_image': null,
        },
      ),
    );

    final page =
        await DalilServiceRemoteDataSource(
          Dio()..httpClientAdapter = adapter,
        ).fetchServices(
          scope: ServiceScope.nearby,
          locale: 'ar',
          page: 1,
          userLat: 33.5,
          userLng: 36.28,
        );
    final service = page.services.single;

    expect(service.distanceText, '0 m');
    expect(service.regionName, 'المزة');
    expect(service.categoryName, 'مطاعم');
  });

  test('a listing that names no mode leaves it unknown', () async {
    final adapter = _CapturingAdapter(_listingBody({'id': 1, 'name': 'Imran'}));

    final page =
        await DalilServiceRemoteDataSource(
          Dio()..httpClientAdapter = adapter,
        ).fetchServices(
          scope: ServiceScope.category,
          scopeId: 1,
          locale: 'ar',
          page: 1,
        );

    expect(page.mode, isNull);
  });
}
