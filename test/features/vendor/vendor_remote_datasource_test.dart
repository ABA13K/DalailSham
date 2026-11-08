import 'dart:convert';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/auth/domain/entities/password_change.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_service_edit.dart';
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

DalilVendorRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilVendorRemoteDataSource(Dio()..httpClientAdapter = adapter);

Map<String, dynamic> _sent(_StubAdapter adapter) {
  final data = adapter.captured?.data;
  return data is String
      ? jsonDecode(data) as Map<String, dynamic>
      : data as Map<String, dynamic>;
}

/// Shaped like the real reply: whole-number coordinates, a null longitude and
/// a local-dev image host.
const _service = {
  'id': 1,
  'name_ar': 'الاسد',
  'name_en': 'amran',
  'is_main': true,
  'region': {'id': 1, 'name': 'المزة'},
  'category': {'id': 1, 'name': 'مطاعم'},
  'address_ar': 'دمشق',
  'address_en': 'damascus',
  'google_maps_url': 'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7',
  'lat': 33,
  'lng': null,
  'description_ar': 'عمران',
  'description_en': 'amran',
  'rating': 0,
  'reviews_count': 0,
  'visits_count': 0,
  'subscription_type': 'free',
  'main_image': 'http://127.0.0.1:8000/storage/join_requests/images/a.png',
  'created_at': '2026-10-27T19:50:52+00:00',
  'updated_at': '2026-10-28T07:36:42+00:00',
};

void main() {
  test('reads the vendor service with the language it asks for', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _service});

    final service = await _dataSource(adapter).service('ar');

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.vendorServicePath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(service.nameAr, 'الاسد');
    expect(service.isMain, isTrue);
    expect(service.regionName, 'المزة');
    expect(service.categoryName, 'مطاعم');
    expect(service.lat, 33.0);
    expect(service.lng, isNull);
    expect(service.subscriptionType, 'free');
    expect(
      service.mainImage,
      'https://dalildimashq.com/storage/join_requests/images/a.png',
    );
  });

  test('a whole reply is the service, not just its names', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _service});

    final service = await _dataSource(adapter).service('ar');

    expect(service.googleMapsUrl, 'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7');
    expect(service.addressEn, 'damascus');
    expect(service.descriptionAr, 'عمران');
    expect(service.rating, 0.0);
    expect(service.visitsCount, 0);
  });

  test('a coordinate saved as text still parses', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': <String, dynamic>{
          ..._service,
          'lat': '33.5138',
          'lng': '36.2765',
          'is_main': 1,
        },
      },
    );

    final service = await _dataSource(adapter).service('en');

    expect(service.lat, 33.5138);
    expect(service.lng, 36.2765);
    expect(service.isMain, isTrue);
  });

  test('an edit reply without region or category still reads', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': <String, dynamic>{
          ..._service,
          'region': null,
          'category': null,
        },
      },
    );

    final service = await _dataSource(adapter).service('ar');

    expect(service.regionName, isNull);
    expect(service.categoryName, isNull);
  });

  test('a reply without a service is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'تم بنجاح'});

    await expectLater(
      _dataSource(adapter).service('ar'),
      throwsA(isA<ParseException>()),
    );
  });

  test('a service missing a name is a parsing failure', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': <String, dynamic>{..._service, 'name_en': null},
      },
    );

    await expectLater(
      _dataSource(adapter).service('ar'),
      throwsA(isA<ParseException>()),
    );
  });

  test('saves the nine fields the edit endpoint takes', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'تم تحديث بيانات الخدمة بنجاح', 'data': _service},
    );

    await _dataSource(adapter).update(
      edit: const VendorServiceEdit(
        nameAr: 'الاسد',
        nameEn: 'amran',
        addressAr: 'دمشق',
        addressEn: 'damascus',
        googleMapsUrl: 'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7',
        lat: 33.5,
        lng: 36.2,
        descriptionAr: 'عمران',
        descriptionEn: 'amran',
      ),
      locale: 'ar',
    );

    expect(adapter.captured?.method, 'PUT');
    expect(adapter.captured?.path, ApiConstants.vendorServicePath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(_sent(adapter), {
      'name_ar': 'الاسد',
      'name_en': 'amran',
      'address_ar': 'دمشق',
      'address_en': 'damascus',
      'google_maps_url': 'https://maps.app.goo.gl/g22L9Fc5YDcy7FCC7',
      'lat': 33.5,
      'lng': 36.2,
      'description_ar': 'عمران',
      'description_en': 'amran',
    });
  });

  test('a cleared field goes out as null', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _service});

    await _dataSource(adapter).update(
      edit: const VendorServiceEdit(nameAr: 'الاسد', nameEn: 'amran'),
      locale: 'en',
    );

    expect(_sent(adapter), {
      'name_ar': 'الاسد',
      'name_en': 'amran',
      'address_ar': null,
      'address_en': null,
      'google_maps_url': null,
      'lat': null,
      'lng': null,
      'description_ar': null,
      'description_en': null,
    });
  });

  test('removes the main image', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Image deleted successfully', 'data': null},
    );

    await _dataSource(adapter).removeMainImage();

    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.vendorMainImagePath);
  });

  test('an image that was never there counts as removed', () async {
    final adapter = _StubAdapter(
      status: 404,
      payload: {'message': 'No image to delete', 'errors': <String, dynamic>{}},
    );

    await expectLater(_dataSource(adapter).removeMainImage(), completes);
  });

  test(
    'changes the vendor password with the keys the endpoint names',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: {'message': 'تم تحديث كلمة المرور بنجاح', 'data': null},
      );

      await _dataSource(adapter).changePassword(
        const PasswordChange(
          currentPassword: 'oldpass123',
          password: 'newpass456',
          confirmation: 'newpass456',
        ),
      );

      expect(adapter.captured?.method, 'POST');
      expect(adapter.captured?.path, ApiConstants.vendorAccountPasswordPath);
      expect(_sent(adapter), {
        'current_password': 'oldpass123',
        'password': 'newpass456',
        'password_confirmation': 'newpass456',
      });
    },
  );

  test('a wrong current password keeps the backend sentence', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'كلمة المرور الحالية غير صحيحة',
        'errors': <String, dynamic>{},
      },
    );

    await expectLater(
      _dataSource(adapter).changePassword(
        const PasswordChange(
          currentPassword: 'nope',
          password: 'newpass456',
          confirmation: 'newpass456',
        ),
      ),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'كلمة المرور الحالية غير صحيحة',
        ),
      ),
    );
  });

  test('a refused edit is named by the field the reply points at', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The given data was invalid.',
        'errors': {
          'google_maps_url': ['The google maps url must be a valid URL.'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).update(
        edit: const VendorServiceEdit(
          nameAr: 'الاسد',
          nameEn: 'amran',
          googleMapsUrl: 'not-a-url',
        ),
        locale: 'ar',
      ),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'The google maps url must be a valid URL.',
        ),
      ),
    );
  });

  test('an account that is not a vendor is refused in its own words', () async {
    final adapter = _StubAdapter(
      status: 403,
      payload: {'message': 'This account is not a vendor'},
    );

    await expectLater(
      _dataSource(adapter).service('ar'),
      throwsA(
        isA<ServerException>().having(
          (e) => e.message,
          'message',
          'This account is not a vendor',
        ),
      ),
    );
  });
}
