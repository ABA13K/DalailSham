import 'dart:convert';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_picker_remote_datasource.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter({required this.status, required this.payload});

  final int status;
  final Object? payload;
  RequestOptions? captured;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    captured = options;
    return ResponseBody.fromString(
      jsonEncode(payload ?? <String, dynamic>{}),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

DalilVendorPickerRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilVendorPickerRemoteDataSource(Dio()..httpClientAdapter = adapter);

const _regions = [
  {'id': 1, 'name': 'المزة'},
  {
    'id': 2,
    'name': 'ابن العماد',
    'image': 'http://127.0.0.1:8000/storage/r.png',
  },
];

void main() {
  test('reads every region with the language it asked for', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'تم بنجاح', 'data': _regions},
    );

    final regions = await _dataSource(adapter).regions(locale: 'ar');

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.vendorRegionsPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(regions.map((region) => region.id), [1, 2]);
    expect(regions.first.name, 'المزة');
  });

  test('adds the text typed in the region field to the search', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _regions});

    await _dataSource(adapter).regions(locale: 'ar', query: ' مزة ');

    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'q': 'مزة'});
  });

  test('a blank region search asks for the whole list', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': []});

    await _dataSource(adapter).regions(locale: 'en', query: '   ');

    expect(adapter.captured?.queryParameters, {'locale': 'en'});
  });

  test('reads every category', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': [
          {'id': 4, 'name': 'مطاعم'},
        ],
      },
    );

    final categories = await _dataSource(adapter).categories(locale: 'ar');

    expect(adapter.captured?.path, ApiConstants.vendorCategoriesPath);
    expect(categories.single.id, 4);
    expect(categories.single.name, 'مطاعم');
  });

  test('searches the categories by name', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': [
          {'id': 4, 'name': 'مطاعم'},
        ],
      },
    );

    await _dataSource(adapter).categories(locale: 'ar', query: 'م');

    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'q': 'م'});
  });

  test(
    'a search that matched nothing is an empty list, not an error',
    () async {
      final adapter = _StubAdapter(status: 200, payload: {'data': []});

      expect(await _dataSource(adapter).regions(locale: 'ar'), isEmpty);
    },
  );

  test('a reply with no data at all is an empty list', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'تم بنجاح'});

    expect(await _dataSource(adapter).categories(locale: 'ar'), isEmpty);
  });

  test('a list of one shape is rejected as unparsable', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': [
          {'id': 1},
        ],
      },
    );

    expect(
      () => _dataSource(adapter).regions(locale: 'ar'),
      throwsA(isA<ParseException>()),
    );
  });

  test('a refusal names the field it rejected', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The given data was invalid.',
        'errors': {
          'locale': ['The selected locale is invalid.'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).regions(locale: 'xx'),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'The selected locale is invalid.',
        ),
      ),
    );
  });

  test('an offline pick list is a network exception', () async {
    final dio = Dio()
      ..httpClientAdapter = _ThrowingAdapter(DioExceptionType.connectionError);

    await expectLater(
      DalilVendorPickerRemoteDataSource(dio).categories(locale: 'ar'),
      throwsA(isA<NetworkException>()),
    );
  });

  test('a slow pick list is a timeout exception', () async {
    final dio = Dio()
      ..httpClientAdapter = _ThrowingAdapter(DioExceptionType.receiveTimeout);

    await expectLater(
      DalilVendorPickerRemoteDataSource(dio).regions(locale: 'ar'),
      throwsA(isA<TimeoutException>()),
    );
  });
}

class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this.type);

  final DioExceptionType type;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async => throw DioException(requestOptions: options, type: type);

  @override
  void close({bool force = false}) {}
}
