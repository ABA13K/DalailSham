import 'dart:convert';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/favorites/data/datasources/favorites_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.payload});

  final int status;
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
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DalilFavoritesRemoteDataSource _dataSource(_StubAdapter adapter) =>
    DalilFavoritesRemoteDataSource(Dio()..httpClientAdapter = adapter);

void main() {
  test('posts the slug to add a favorite', () async {
    final adapter = _StubAdapter(
      status: 201,
      payload: {
        'message': 'Added to favorites',
        'data': {'is_favorited': true, 'service_id': 2, 'favorites_count': 1},
      },
    );

    final mutation = await _dataSource(adapter).favorite('amran-1');

    expect(adapter.captured?.method, 'POST');
    expect(
      adapter.captured?.path,
      '${ApiConstants.favoritesServicesPath}/amran-1',
    );
    expect(mutation.isFavorited, isTrue);
    expect(mutation.message, 'Added to favorites');
  });

  test('deletes the slug to remove a favorite', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'Removed from favorites',
        'data': {'is_favorited': false, 'service_id': 2, 'favorites_count': 0},
      },
    );

    final mutation = await _dataSource(adapter).unfavorite('amran-1');

    expect(adapter.captured?.method, 'DELETE');
    expect(mutation.isFavorited, isFalse);
    expect(mutation.message, 'Removed from favorites');
  });

  test('a duplicate add resolves to favorited', () async {
    final adapter = _StubAdapter(
      status: 409,
      payload: {
        'message': 'This service is already in your favorites',
        'errors': [],
      },
    );

    final mutation = await _dataSource(adapter).favorite('amran-1');

    expect(mutation.isFavorited, isTrue);
    expect(mutation.message, 'This service is already in your favorites');
  });

  test('removing an unknown favorite resolves to not favorited', () async {
    final adapter = _StubAdapter(
      status: 404,
      payload: {
        'message': 'This service is not in your favorites',
        'errors': [],
      },
    );

    final mutation = await _dataSource(adapter).unfavorite('amran-1');

    expect(mutation.isFavorited, isFalse);
  });

  test(
    'an unapproved account keeps the add failed with the backend message',
    () async {
      final adapter = _StubAdapter(
        status: 404,
        payload: {
          'message': 'You do not have a registered service.',
          'errors': [],
        },
      );

      await expectLater(
        _dataSource(adapter).favorite('amran-1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'You do not have a registered service.',
          ),
        ),
      );
    },
  );

  test(
    'falls back to the status code when the body carries no message',
    () async {
      final adapter = _StubAdapter(status: 401, payload: {});

      await expectLater(
        _dataSource(adapter).favorite('amran-1'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            'HTTP 401',
          ),
        ),
      );
    },
  );
}
