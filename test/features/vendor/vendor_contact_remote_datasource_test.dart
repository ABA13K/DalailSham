import 'dart:convert';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_contact_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_contact_edit.dart';
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

class _ThrowingAdapter implements HttpClientAdapter {
  _ThrowingAdapter(this.error);

  final DioException error;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) => throw error;

  @override
  void close({bool force = false}) {}
}

DalilVendorContactRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilVendorContactRemoteDataSource(Dio()..httpClientAdapter = adapter);

const _edit = VendorContactEdit(type: 'whatsapp', value: '+9630933314349');

const _created = {
  'id': 11,
  'type': 'whatsapp',
  'type_label': 'واتساب',
  'value': '+9630933314349',
  'is_primary': false,
};

/// The grouped reply names the type once, on the group, and leaves its rows
/// with only what differs between them.
const _groups = [
  {
    'type': 'phone',
    'type_label': 'هاتف',
    'count': 2,
    'has_primary': true,
    'primary': {'id': 2, 'value': '0999111222'},
    'contacts': [
      {'id': 2, 'value': '0999111222', 'is_primary': true},
      {'id': 3, 'value': '0999111333', 'is_primary': false},
    ],
  },
  {
    'type': 'email',
    'type_label': 'بريد إلكتروني',
    'count': 1,
    'has_primary': false,
    'primary': null,
    'contacts': [
      {'id': 6, 'value': 'amran1@gmail.com', 'is_primary': false},
    ],
  },
];

void main() {
  test('reads the types with the language it asked for', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'تم بنجاح',
        'data': [
          {'value': 'phone', 'label': 'هاتف'},
          {'value': 'website', 'label': 'موقع إلكتروني'},
        ],
      },
    );

    final types = await _dataSource(adapter).types('ar');

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.vendorContactTypesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(types.map((type) => type.value), ['phone', 'website']);
    expect(types.first.label, 'هاتف');
  });

  test('a type without either field is not a choice the form gets', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': [
          {'value': 'phone'},
        ],
      },
    );

    await expectLater(
      _dataSource(adapter).types('ar'),
      throwsA(isA<ParseException>()),
    );
  });

  test('reads the contacts grouped, with the type its rows share', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'تم بنجاح', 'data': _groups},
    );

    final groups = await _dataSource(adapter).contacts('ar');

    expect(adapter.captured?.path, ApiConstants.vendorContactsPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(groups.map((group) => group.type), ['phone', 'email']);
    expect(groups.first.typeLabel, 'هاتف');
    expect(groups.first.count, 2);
    expect(groups.first.hasPrimary, isTrue);
    expect(groups.first.primary?.id, 2);
    expect(groups.first.contacts.map((contact) => contact.type), [
      'phone',
      'phone',
    ]);
    // The rows arrive nameless; the label printed beside one is its group's.
    expect(groups.first.contacts.map((contact) => contact.typeLabel), [
      'هاتف',
      'هاتف',
    ]);
    expect(groups.last.contacts.single.value, 'amran1@gmail.com');
    expect(groups.last.hasPrimary, isFalse);
  });

  test('a vendor with no contacts is an empty list, not an error', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'تم بنجاح'});

    expect(await _dataSource(adapter).contacts('ar'), isEmpty);
  });

  test(
    'a group that never names its type is not one the page can show',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: {
          'data': [
            {'type_label': 'هاتف', 'contacts': []},
          ],
        },
      );

      await expectLater(
        _dataSource(adapter).contacts('ar'),
        throwsA(isA<ParseException>()),
      );
    },
  );

  test(
    'adding sends the type and the value and answers with the line',
    () async {
      final adapter = _StubAdapter(
        status: 201,
        payload: {'message': 'تمت إضافة جهة الاتصال بنجاح', 'data': _created},
      );

      final contact = await _dataSource(adapter).add(edit: _edit, locale: 'ar');

      expect(adapter.captured?.method, 'POST');
      expect(adapter.captured?.path, ApiConstants.vendorContactsPath);
      expect(adapter.captured?.queryParameters, {'locale': 'ar'});
      expect(adapter.captured?.data, {
        'type': 'whatsapp',
        'value': '+9630933314349',
      });
      expect(contact.id, 11);
      expect(contact.typeLabel, 'واتساب');
      expect(contact.isPrimary, isFalse);
    },
  );

  test(
    'editing puts the same two fields on the line named by its id',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: {
          'message': 'تم تحديث جهة الاتصال بنجاح',
          'data': {
            'id': 6,
            'type': 'email',
            'type_label': 'بريد إلكتروني',
            'value': 'amran1@gmail.com',
            'is_primary': false,
          },
        },
      );

      final contact = await _dataSource(adapter).update(
        id: 6,
        edit: const VendorContactEdit(type: 'email', value: 'amran1@gmail.com'),
        locale: 'ar',
      );

      expect(adapter.captured?.method, 'PUT');
      expect(adapter.captured?.path, ApiConstants.vendorContactPath(6));
      expect(contact.id, 6);
      expect(contact.type, 'email');
    },
  );

  test('deleting names the line and needs no reply body', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Contact deleted successfully', 'data': null},
    );

    await _dataSource(adapter).remove(id: 1, locale: 'ar');

    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.vendorContactPath(1));
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
  });

  test('setting the primary line posts to its own path with no body', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'تم تعيين جهة الاتصال كرئيسية لهذا النوع',
        'data': {
          'id': 2,
          'type': 'phone',
          'type_label': 'هاتف',
          'value': '0999111222',
          'is_primary': true,
        },
      },
    );

    final contact = await _dataSource(adapter).setPrimary(id: 2, locale: 'ar');

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.vendorContactPrimaryPath(2));
    expect(contact.isPrimary, isTrue);
  });

  test('a write that answers with nothing leaves the page guessing', () async {
    final adapter = _StubAdapter(
      status: 201,
      payload: {'message': 'تمت إضافة جهة الاتصال بنجاح'},
    );

    await expectLater(
      _dataSource(adapter).add(edit: _edit, locale: 'ar'),
      throwsA(isA<ParseException>()),
    );
  });

  test('a validation reply is shown with the field it names', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The selected type is invalid.',
        'errors': {
          'type': ['The selected type is invalid.'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).add(edit: _edit, locale: 'ar'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'The selected type is invalid.',
        ),
      ),
    );
  });

  test('a dead connection is a network failure', () async {
    final adapter = _ThrowingAdapter(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionError,
      ),
    );

    await expectLater(
      _dataSource(adapter).contacts('ar'),
      throwsA(isA<NetworkException>()),
    );
  });

  test('a stalled request is a timeout failure', () async {
    final adapter = _ThrowingAdapter(
      DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.receiveTimeout,
      ),
    );

    await expectLater(
      _dataSource(adapter).types('ar'),
      throwsA(isA<TimeoutException>()),
    );
  });
}
