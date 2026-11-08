import 'dart:convert';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_amenity_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_amenity_edit.dart';
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

DalilVendorAmenityRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilVendorAmenityRemoteDataSource(Dio()..httpClientAdapter = adapter);

/// An amenity as the endpoint answers it: both names while the vendor wrote
/// them, and the server's own word for how far it got.
const _wifi = <String, dynamic>{
  'id': 1,
  'name_ar': 'واي فاي',
  'name_en': 'Wi-Fi',
  'status': 'approved',
  'is_approved': true,
  'is_pending': false,
};

/// The line a write leaves behind, waiting for an admin.
const _pending = <String, dynamic>{
  'id': 2,
  'name_ar': 'قاعة اجتماعات',
  'name_en': 'Conference Rooms',
  'status': 'pending',
  'is_approved': false,
  'is_pending': true,
};

/// The gallery envelope. A null [canAdd] stands for the reply leaving the word
/// out, which the reader then works out from the count and the limit.
Map<String, dynamic> _gallery(
  List<Map<String, dynamic>> rows, {
  int maxAllowed = 20,
  bool? canAdd,
}) => <String, dynamic>{
  'message': 'تم بنجاح',
  'data': <String, dynamic>{
    'count': rows.length,
    'max_allowed': maxAllowed,
    'can_add': canAdd,
    'amenities': rows,
  },
};

const _edit = VendorAmenityEdit(
  nameAr: 'قاعة اجتماعات',
  nameEn: 'Conference Rooms',
);

void main() {
  test('the list carries the amenities, the limit and the room left', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _gallery([_wifi, _pending], canAdd: true),
    );

    final gallery = await _dataSource(adapter).gallery('ar');

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.vendorAmenitiesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(gallery.amenities.map((amenity) => amenity.id), const [1, 2]);
    expect(gallery.maxAllowed, 20);
    expect(gallery.canAdd, isTrue);
    expect(gallery.count, 2);
  });

  test('a row shows both names and the language the page asks for', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _gallery([_wifi], canAdd: true),
    );

    final amenity = (await _dataSource(adapter).gallery('en')).amenities.single;

    expect(amenity.nameIn('en'), 'Wi-Fi');
    expect(amenity.nameIn('ar'), 'واي فاي');
    expect(amenity.otherName('en'), 'واي فاي');
    expect(amenity.otherName('ar'), 'Wi-Fi');
    expect(amenity.isApproved, isTrue);
    expect(amenity.status, 'approved');
  });

  test(
    'a row the vendor wrote in Arabic alone falls back to that name',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: _gallery([
          {
            'id': 5,
            'name_ar': 'مواقف سيارات',
            'name_en': null,
            'status': 'pending',
          },
        ]),
      );

      final amenity = (await _dataSource(
        adapter,
      ).gallery('en')).amenities.single;

      expect(amenity.nameEn, isNull);
      expect(amenity.nameIn('en'), 'مواقف سيارات');
      expect(amenity.otherName('en'), isNull);
      // The word stands where the flag the endpoint left out would have.
      expect(amenity.isApproved, isFalse);
    },
  );

  test('the server word alone marks an amenity approved', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _gallery([
        {'id': 6, 'name_ar': 'تكييف', 'status': 'approved'},
      ]),
    );

    final amenity = (await _dataSource(adapter).gallery('ar')).amenities.single;

    expect(amenity.isApproved, isTrue);
  });

  test(
    'a missing room flag is worked out from the count and the limit',
    () async {
      final filled = _StubAdapter(
        status: 200,
        payload: _gallery([_wifi, _pending], maxAllowed: 2),
      );
      final spare = _StubAdapter(
        status: 200,
        payload: _gallery([_wifi], maxAllowed: 20),
      );

      final fullGallery = await _dataSource(filled).gallery('en');
      final roomGallery = await _dataSource(spare).gallery('en');

      expect(fullGallery.canAdd, isFalse);
      expect(roomGallery.canAdd, isTrue);
    },
  );

  test('a reply with no gallery behind it is not an empty set', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'تم بنجاح'});

    await expectLater(
      _dataSource(adapter).gallery('ar'),
      throwsA(isA<ParseException>()),
    );
  });

  test(
    'a row with no Arabic name fails the page rather than showing blank',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: _gallery([
          {'id': 8, 'name_ar': '  ', 'status': 'pending'},
        ]),
      );

      await expectLater(
        _dataSource(adapter).gallery('en'),
        throwsA(isA<ParseException>()),
      );
    },
  );

  test('adding sends the two names as JSON', () async {
    final adapter = _StubAdapter(status: 201, payload: {'data': _pending});

    final amenity = await _dataSource(adapter).add(edit: _edit, locale: 'ar');

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.vendorAmenitiesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(adapter.captured?.data, {
      'name_ar': 'قاعة اجتماعات',
      'name_en': 'Conference Rooms',
    });
    expect(amenity.id, 2);
    expect(amenity.status, 'pending');
    expect(amenity.isApproved, isFalse);
  });

  test(
    'a name the vendor left out is sent empty rather than missing',
    () async {
      final adapter = _StubAdapter(status: 201, payload: {'data': _pending});

      await _dataSource(adapter).add(
        edit: const VendorAmenityEdit(nameAr: 'واي فاي'),
        locale: 'en',
      );

      expect(adapter.captured?.data, {'name_ar': 'واي فاي', 'name_en': ''});
    },
  );

  test(
    'an amenity that already exists is answered with its own sentence',
    () async {
      final adapter = _StubAdapter(
        status: 409,
        payload: {
          'message': 'This amenity already exists',
          'errors': <String, dynamic>{},
        },
      );

      await expectLater(
        _dataSource(adapter).add(edit: _edit, locale: 'ar'),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'message',
            'This amenity already exists',
          ),
        ),
      );
    },
  );

  test('a validation reply names the field, and that is what shows', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The given data was invalid.',
        'errors': {
          'name_ar': ['حقل الميزة مطلوب'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).add(edit: _edit, locale: 'ar'),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'حقل الميزة مطلوب',
        ),
      ),
    );
  });

  test('a refusal that says nothing leaves the status code to speak', () async {
    final adapter = _StubAdapter(status: 403, payload: {});

    await expectLater(
      _dataSource(adapter).remove(id: 2, locale: 'ar'),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'HTTP 403',
        ),
      ),
    );
  });

  test(
    'a write that stored nothing is a failure, not a silent success',
    () async {
      final adapter = _StubAdapter(status: 201, payload: {'message': 'done'});

      await expectLater(
        _dataSource(adapter).add(edit: _edit, locale: 'en'),
        throwsA(isA<ParseException>()),
      );
    },
  );

  test('editing names the amenity in the path', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _pending});

    final amenity = await _dataSource(
      adapter,
    ).update(id: 2, edit: _edit, locale: 'ar');

    expect(adapter.captured?.method, 'PUT');
    expect(adapter.captured?.path, ApiConstants.vendorAmenityPath(2));
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(adapter.captured?.data, {
      'name_ar': 'قاعة اجتماعات',
      'name_en': 'Conference Rooms',
    });
    // The rewritten line waits for an admin again, and the reply says so.
    expect(amenity.status, 'pending');
  });

  test('deleting one amenity names it in the path', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Amenity deleted', 'data': null},
    );

    await _dataSource(adapter).remove(id: 2, locale: 'ar');

    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.vendorAmenityPath(2));
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
  });

  test(
    'clearing deletes the collection and keeps the count it removed',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: {
          'message': 'All amenities deleted (1 amenities)',
          'data': {'deleted': 1},
        },
      );

      expect(await _dataSource(adapter).clear('ar'), 1);
      expect(adapter.captured?.method, 'DELETE');
      expect(adapter.captured?.path, ApiConstants.vendorAmenitiesPath);
      expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    },
  );

  test('a clear that counts nothing removed says so with zero', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'All amenities deleted (0 amenities)', 'data': null},
    );

    expect(await _dataSource(adapter).clear('en'), 0);
  });
}
