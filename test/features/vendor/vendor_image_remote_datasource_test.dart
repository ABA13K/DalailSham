import 'dart:convert';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_image_remote_datasource.dart';
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

DalilVendorImageRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilVendorImageRemoteDataSource(Dio()..httpClientAdapter = adapter);

const _image = {
  'id': 1,
  'image': 'https://dalildimashq.com/storage/app/public/services/images/a.png',
  'is_approved': false,
  'sort_order': 1,
};

Map<String, dynamic> _gallery(
  List<Map<String, dynamic>> images, {
  Object? canAdd,
  int max = 20,
}) => <String, dynamic>{
  'message': 'Done',
  'data': <String, dynamic>{
    'count': images.length,
    'max_allowed': max,
    'can_add': ?canAdd,
    'images': images,
  },
};

void main() {
  test('the gallery reads the pictures, the limit and the room left', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _gallery([
        _image,
        {
          'id': 2,
          'image': 'http://127.0.0.1/storage/app/public/services/images/b.png',
          'is_approved': true,
          'sort_order': 2,
        },
      ], canAdd: true),
    );

    final gallery = await _dataSource(adapter).gallery('ar');

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.vendorImagesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(gallery.maxAllowed, 20);
    expect(gallery.canAdd, isTrue);
    expect(gallery.images, hasLength(2));
    expect(gallery.images.first.id, 1);
    expect(gallery.images.first.isApproved, isFalse);
    expect(gallery.images.first.sortOrder, 1);
    // A storage address on the dev host still has to load on a device.
    expect(
      gallery.images.last.url,
      'https://dalildimashq.com/storage/app/public/services/images/b.png',
    );
  });

  test('a reply that says the set is full closes the add', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _gallery([_image], canAdd: false, max: 1),
    );

    final gallery = await _dataSource(adapter).gallery('en');

    expect(gallery.canAdd, isFalse);
  });

  test('without the word the count against the limit decides', () async {
    final room = _StubAdapter(status: 200, payload: _gallery([_image]));
    final full = _StubAdapter(status: 200, payload: _gallery([_image], max: 1));

    expect((await _dataSource(room).gallery('en')).canAdd, isTrue);
    expect((await _dataSource(full).gallery('en')).canAdd, isFalse);
  });

  test('an empty set is a gallery with nothing in it', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _gallery(const [], canAdd: true),
    );

    final gallery = await _dataSource(adapter).gallery('en');

    expect(gallery.images, isEmpty);
    expect(gallery.canAdd, isTrue);
  });

  test('adding posts the chosen file under the image field', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _image});

    final image = await _dataSource(adapter).add(
      file: AvatarFile(
        bytes: Uint8List.fromList([1, 2, 3]),
        fileName: 'shop.png',
      ),
      locale: 'ar',
    );

    final form = adapter.captured?.data as FormData;
    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.vendorImagesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(form.files.single.key, 'image');
    expect(form.files.single.value.filename, 'shop.png');
    expect(image.id, 1);
    expect(image.isApproved, isFalse);
  });

  test('deleting one picture names its id in the path', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Image deleted', 'data': null},
    );

    await _dataSource(adapter).remove(id: 7, locale: 'en');

    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.vendorImagePath(7));
    expect(adapter.captured?.queryParameters, {'locale': 'en'});
  });

  test('deleting every picture counts what went away', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'All images deleted (2 images)',
        'data': <String, dynamic>{'deleted': 2},
      },
    );

    expect(await _dataSource(adapter).clear('ar'), 2);
    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.vendorImagesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
  });

  test('a clear answer that counts nothing is zero removed', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'All images deleted', 'data': null},
    );

    expect(await _dataSource(adapter).clear('en'), 0);
  });

  test('a refused upload shows the sentence about the file', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The given data was invalid.',
        'errors': <String, dynamic>{
          'image': <dynamic>['The image must be an image.'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).add(
        file: AvatarFile(bytes: Uint8List(0), fileName: 'note.txt'),
        locale: 'en',
      ),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'The image must be an image.',
        ),
      ),
    );
  });

  test('a gallery reply without its data is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'Done'});

    await expectLater(
      _dataSource(adapter).gallery('en'),
      throwsA(isA<ParseException>()),
    );
  });
}
