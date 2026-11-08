import 'dart:convert';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/network/api_client.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_product_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_query.dart';
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

DalilVendorProductRemoteDataSource _dataSource(HttpClientAdapter adapter) =>
    DalilVendorProductRemoteDataSource(Dio()..httpClientAdapter = adapter);

/// The write calls are multipart because the picture rides with them, so the
/// text fields come back off the [FormData] rather than a JSON body.
Map<String, String> _fields(_StubAdapter adapter) {
  final form = adapter.captured?.data as FormData;
  return {for (final entry in form.fields) entry.key: entry.value};
}

Map<String, MultipartFile> _files(_StubAdapter adapter) {
  final form = adapter.captured?.data as FormData;
  return {for (final entry in form.files) entry.key: entry.value};
}

/// A row as `GET /vendor/products` answers it: the Arabic name always, the
/// English half only when the vendor filled it, and a decimal price the backend
/// may hand back as a string.
const _coffee = <String, dynamic>{
  'id': 3,
  'name_ar': 'قهوة',
  'name_en': 'Coffee',
  'description_ar': 'قهوة عربية',
  'description_en': '',
  'category': {'id': 4, 'name': 'مقاهي'},
  'price': '1200.00',
  'quantity': 4,
  'image': 'http://127.0.0.1/storage/vendor/products/3.png',
  'is_active': true,
  'is_available': false,
  'is_approved': false,
};

const _juice = <String, dynamic>{
  'id': 7,
  'name_ar': 'عصير',
  'price': 9000,
  'is_active': 1,
  'is_available': 1,
  'is_approved': 1,
};

Map<String, dynamic> _listing(
  List<Map<String, dynamic>> rows, {
  bool hasMore = false,
  int? nextPage,
  int? count,
}) => <String, dynamic>{
  'message': 'تم بنجاح',
  'locale': 'ar',
  'count': count ?? rows.length,
  'pagination': <String, dynamic>{
    'current_page': nextPage == null ? 1 : 2,
    'per_page': 20,
    'total': rows.length,
    'last_page': 1,
    'has_more': hasMore,
    'next_page': nextPage,
    'prev_page': null,
  },
  'links': <String, dynamic>{},
  'data': rows,
};

const _edit = VendorProductEdit(
  categoryId: 4,
  nameAr: 'قهوة',
  nameEn: 'Coffee',
  descriptionAr: 'قهوة عربية',
  price: 1200,
  quantity: 4,
);

final _photo = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'coffee.png',
);

void main() {
  test('the categories arrive as a plain list of names', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'message': 'تم بنجاح',
        'data': [
          {'id': 4, 'name': 'مقاهي'},
          {'id': 5, 'name': 'مطاعم'},
        ],
      },
    );

    final categories = await _dataSource(adapter).categories(locale: 'ar');

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.vendorProductCategoriesPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(categories.map((category) => category.name), const [
      'مقاهي',
      'مطاعم',
    ]);
  });

  test('the words typed narrow the list as q', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {
        'data': [
          {'id': 4, 'name': 'مشروب ساخن'},
        ],
      },
    );

    await _dataSource(adapter).categories(locale: 'ar', query: ' مشروب ');

    expect(adapter.captured?.queryParameters, {'locale': 'ar', 'q': 'مشروب'});
  });

  test(
    'nothing typed asks for the whole list, not a match against nothing',
    () async {
      final adapter = _StubAdapter(status: 200, payload: {'data': <Object>[]});

      final categories = await _dataSource(
        adapter,
      ).categories(locale: 'en', query: '   ');

      expect(adapter.captured?.queryParameters, {'locale': 'en'});
      expect(categories, isEmpty);
    },
  );

  test('a category reply that carries no list is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': 'nope'});

    await expectLater(
      _dataSource(adapter).categories(locale: 'en'),
      throwsA(isA<ParseException>()),
    );
  });

  test('the listing sends the page it was asked for', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _listing([_coffee], count: 41),
    );

    final page = await _dataSource(
      adapter,
    ).products(const VendorProductQuery(locale: 'ar'));

    expect(adapter.captured?.method, 'GET');
    expect(adapter.captured?.path, ApiConstants.vendorProductsPath);
    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'per_page': 20,
      'page': 1,
    });
    expect(page.products, hasLength(1));
    expect(page.count, 41);
    expect(page.hasMore, isFalse);
    expect(page.nextPage, isNull);
  });

  test(
    'a row keeps both names, the category and the flags it was stored with',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: _listing([_coffee, _juice]),
      );

      final page = await _dataSource(
        adapter,
      ).products(const VendorProductQuery(locale: 'ar'));

      final coffee = page.products.first;
      expect(coffee.id, 3);
      expect(coffee.nameAr, 'قهوة');
      expect(coffee.nameEn, 'Coffee');
      // An empty description is not a description.
      expect(coffee.descriptionEn, isNull);
      expect(coffee.categoryId, 4);
      expect(coffee.categoryName, 'مقاهي');
      // A decimal column answers "1200.00".
      expect(coffee.price, 1200);
      expect(coffee.quantity, 4);
      expect(coffee.isActive, isTrue);
      expect(coffee.isAvailable, isFalse);
      expect(coffee.isApproved, isFalse);
      // A storage address on the dev host still has to load on a device.
      expect(
        coffee.imageUrl,
        'https://dalildimashq.com/storage/vendor/products/3.png',
      );

      // The other row answers `1`/`0` and carries no English half at all.
      final juice = page.products.last;
      expect(juice.nameEn, isNull);
      expect(juice.price, 9000);
      expect(juice.quantity, isNull);
      expect(juice.isApproved, isTrue);
    },
  );

  test('only the filters the vendor chose travel', () async {
    final adapter = _StubAdapter(status: 200, payload: _listing(const []));

    await _dataSource(adapter).products(
      const VendorProductQuery(
        locale: 'ar',
        page: 2,
        categoryId: 4,
        status: VendorProductStatus.pending,
        text: 'قهوة',
      ),
    );

    expect(adapter.captured?.queryParameters, {
      'locale': 'ar',
      'per_page': 20,
      'page': 2,
      'q': 'قهوة',
      'product_category_id': 4,
      'status': 'pending',
    });
  });

  test(
    'each approval state is spelled the way the parameter spells it',
    () async {
      for (final status in VendorProductStatus.values) {
        final adapter = _StubAdapter(status: 200, payload: _listing(const []));

        await _dataSource(
          adapter,
        ).products(VendorProductQuery(locale: 'en', status: status));

        expect(adapter.captured?.queryParameters['status'], status.wire);
      }
    },
  );

  test(
    'a page that says more is coming hands the next page number up',
    () async {
      final adapter = _StubAdapter(
        status: 200,
        payload: _listing([_coffee], hasMore: true, nextPage: 2),
      );

      final page = await _dataSource(
        adapter,
      ).products(const VendorProductQuery(locale: 'en'));

      expect(page.hasMore, isTrue);
      expect(page.nextPage, 2);
    },
  );

  test('a listing reply without its rows is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'تم بنجاح'});

    await expectLater(
      _dataSource(adapter).products(const VendorProductQuery(locale: 'en')),
      throwsA(isA<ParseException>()),
    );
  });

  test('a row with no name in either language fails the page', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: _listing([
        {'id': 8, 'name_ar': '  '},
      ]),
    );

    await expectLater(
      _dataSource(adapter).products(const VendorProductQuery(locale: 'en')),
      throwsA(isA<ParseException>()),
    );
  });

  test('adding posts the fields and the picture together', () async {
    final adapter = _StubAdapter(status: 201, payload: {'data': _coffee});

    final product = await _dataSource(
      adapter,
    ).add(edit: _edit, image: _photo, locale: 'ar');

    expect(adapter.captured?.method, 'POST');
    expect(adapter.captured?.path, ApiConstants.vendorProductsPath);
    expect(adapter.captured?.queryParameters, {'locale': 'ar'});
    expect(_fields(adapter), {
      'product_category_id': '4',
      'name_ar': 'قهوة',
      'name_en': 'Coffee',
      'description_ar': 'قهوة عربية',
      'description_en': '',
      'price': '1200.0',
      'quantity': '4',
    });
    expect(_files(adapter).keys, ['image']);
    expect(_files(adapter)['image']?.filename, 'coffee.png');
    expect(product.id, 3);
    expect(product.isApproved, isFalse);
  });

  test(
    'a new product sends no flags, because the endpoint takes none',
    () async {
      final adapter = _StubAdapter(status: 200, payload: {'data': _juice});

      await _dataSource(adapter).add(edit: _edit, locale: 'ar');

      expect(_fields(adapter), isNot(contains('is_active')));
      expect(_fields(adapter), isNot(contains('is_available')));
      expect(_files(adapter), isEmpty);
    },
  );

  test('an omitted half is sent empty rather than left out', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _juice});

    await _dataSource(adapter).add(
      edit: const VendorProductEdit(categoryId: 4, nameAr: 'عصير', price: 9000),
      locale: 'ar',
    );

    expect(_fields(adapter)['name_en'], '');
    expect(_fields(adapter), isNot(contains('quantity')));
  });

  test(
    'editing names the product in the path and sends the two flags',
    () async {
      final adapter = _StubAdapter(status: 200, payload: {'data': _coffee});

      await _dataSource(adapter).update(
        id: 3,
        edit: const VendorProductEdit(
          categoryId: 4,
          nameAr: 'قهوة',
          price: 1200,
          isActive: false,
          isAvailable: true,
        ),
        locale: 'en',
      );

      expect(adapter.captured?.method, 'PUT');
      expect(adapter.captured?.path, ApiConstants.vendorProductPath(3));
      expect(adapter.captured?.queryParameters, {'locale': 'en'});
      expect(_fields(adapter)['is_active'], '0');
      expect(_fields(adapter)['is_available'], '1');
    },
  );

  test('a flag the edit did not touch is not sent at all', () async {
    final adapter = _StubAdapter(status: 200, payload: {'data': _coffee});

    await _dataSource(adapter).update(
      id: 3,
      edit: const VendorProductEdit(
        categoryId: 4,
        nameAr: 'قهوة',
        price: 1200,
        isActive: true,
      ),
      locale: 'en',
    );

    expect(_fields(adapter)['is_active'], '1');
    expect(_fields(adapter), isNot(contains('is_available')));
  });

  test('deleting names the product in the path', () async {
    final adapter = _StubAdapter(
      status: 200,
      payload: {'message': 'Product deleted successfully', 'data': null},
    );

    await _dataSource(adapter).remove(id: 7, locale: 'en');

    expect(adapter.captured?.method, 'DELETE');
    expect(adapter.captured?.path, ApiConstants.vendorProductPath(7));
    expect(adapter.captured?.queryParameters, {'locale': 'en'});
  });

  test('a refused write shows the sentence about the field', () async {
    final adapter = _StubAdapter(
      status: 422,
      payload: {
        'message': 'The given data was invalid.',
        'errors': <String, dynamic>{
          'price': <dynamic>['The price must be a number.'],
        },
      },
    );

    await expectLater(
      _dataSource(adapter).add(edit: _edit, locale: 'en'),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'The price must be a number.',
        ),
      ),
    );
  });

  test('a refusal that names nothing falls back to the status', () async {
    final adapter = _StubAdapter(status: 403, payload: <String, dynamic>{});

    await expectLater(
      _dataSource(adapter).remove(id: 7, locale: 'en'),
      throwsA(
        isA<ServerException>().having(
          (error) => error.message,
          'message',
          'HTTP 403',
        ),
      ),
    );
  });

  test('a write that stores nothing is a parsing failure', () async {
    final adapter = _StubAdapter(status: 200, payload: {'message': 'تم بنجاح'});

    await expectLater(
      _dataSource(adapter).add(edit: _edit, locale: 'ar'),
      throwsA(isA<ParseException>()),
    );
  });
}
