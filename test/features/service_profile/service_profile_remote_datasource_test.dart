import 'dart:convert';

import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/service_profile/data/datasources/service_profile_remote_datasource.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_review.dart';
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

Map<String, dynamic> _reviewsBody() => {
  'locale': 'ar',
  'service': {'slug': 'amran', 'name': 'الاسد', 'reviews_count': 1},
  'summary': {
    'average_rating': 4.4,
    'total_reviews': 1,
    'rating_breakdown': {'5': 1, '4': 0, '3': 0, '2': 0, '1': 0},
  },
  'sort': 'highest',
  'count': 1,
  'pagination': {
    'current_page': 1,
    'per_page': 20,
    'total': 1,
    'last_page': 1,
    'has_more': false,
    'next_page': null,
  },
  'data': [
    {
      'id': 35,
      'rating': 5,
      'comment': 'Amazing restaurant!',
      'is_mine': true,
      'user': {'id': 9, 'name': 'Ali', 'avatar': null},
      'created_at': '2026-11-06T20:17:58+03:00',
    },
  ],
};

Map<String, dynamic> _detailBody() => {
  'locale': 'ar',
  'is_authenticated': true,
  'is_favorited': false,
  'data': {
    'id': 1,
    'name': 'الاسد',
    'slug': 'amran',
    'rating': 0,
    'reviews_count': 0,
    'counts': {'images_count': 0, 'products_count': 0, 'reviews_count': 0},
  },
};

Map<String, dynamic> _productsBody() => {
  'locale': 'ar',
  'sort': 'default',
  'count': 0,
  'pagination': {
    'current_page': 1,
    'per_page': 10,
    'total': 0,
    'last_page': 1,
    'has_more': false,
    'next_page': null,
  },
  'data': [],
};

void main() {
  test('the public reviews path sits under the service', () async {
    final adapter = _CapturingAdapter(_reviewsBody());
    final dataSource = DalilServiceProfileRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    final page = await dataSource.fetchReviews(
      slug: 'amran',
      locale: 'ar',
      page: 1,
      sort: ServiceReviewSort.highest,
    );

    expect(
      adapter.captured?.path,
      '${ApiConstants.dalilBaseUrl}/services/amran/reviews',
    );
    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'page': 1,
      'sort': 'highest',
    });
    expect(page.reviews.single.comment, 'Amazing restaurant!');
    expect(page.reviews.single.isMine, isTrue);
    expect(page.summary.averageRating, 4.4);
    expect(page.summary.countFor(5), 1);
    expect(page.sort, ServiceReviewSort.highest);
  });

  // The signed-in reading lives under `/user/services`, like the signed-in
  // details. `/userservices` answers 404 and used to hide every comment.
  test('the signed-in reviews path is under /user/services', () async {
    final adapter = _CapturingAdapter(_reviewsBody());
    final dataSource = DalilServiceProfileRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    await dataSource.fetchReviews(
      slug: 'amran',
      locale: 'ar',
      page: 1,
      sort: ServiceReviewSort.latest,
      authenticated: true,
    );

    expect(
      adapter.captured?.path,
      '${ApiConstants.dalilBaseUrl}/user/services/amran/reviews',
    );
  });

  test('the signed-in details path is under /user/services', () async {
    final adapter = _CapturingAdapter(_detailBody());
    final dataSource = DalilServiceProfileRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    await dataSource.fetchDetail(
      slug: 'amran',
      locale: 'ar',
      authenticated: true,
    );

    expect(
      adapter.captured?.path,
      '${ApiConstants.dalilBaseUrl}/user/services/amran',
    );
  });

  test('distance is only sent when both coordinates exist', () async {
    final adapter = _CapturingAdapter(_detailBody());
    final dataSource = DalilServiceProfileRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    await dataSource.fetchDetail(
      slug: 'amran',
      locale: 'ar',
      userLat: 33.5298611,
      userLng: 36.23375,
    );

    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'user_lat': 33.5298611,
      'user_lng': 36.23375,
      'sort': 'distance',
    });
  });

  test('one category narrows the products path', () async {
    final adapter = _CapturingAdapter(_productsBody());
    final dataSource = DalilServiceProfileRemoteDataSource(
      Dio()..httpClientAdapter = adapter,
    );

    await dataSource.fetchProducts(
      slug: 'amran',
      locale: 'ar',
      page: 2,
      categorySlug: 'hot-drinks-tAxW',
    );

    expect(
      adapter.captured?.path,
      '${ApiConstants.dalilBaseUrl}/services/amran/categories/hot-drinks-tAxW/products',
    );
    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'page': 2});
  });
}
