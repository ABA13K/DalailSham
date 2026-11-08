import 'dart:typed_data';

import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_product_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/data/repositories/vendor_product_repository_impl.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_page.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorProductRemoteDataSource extends Mock
    implements VendorProductRemoteDataSource {}

const _coffee = VendorProduct(
  id: 3,
  nameAr: 'قهوة',
  nameEn: 'Coffee',
  categoryId: 4,
  categoryName: 'مقاهي',
  price: 1200,
  quantity: 4,
  imageUrl: 'https://dalildimashq.com/storage/vendor/products/3.png',
);

const _juice = VendorProduct(
  id: 7,
  nameAr: 'عصير',
  price: 9000,
  isApproved: true,
);

const _page = VendorProductPage(
  products: [_coffee],
  hasMore: true,
  nextPage: 2,
  count: 41,
);

const _emptyPage = VendorProductPage(products: [], hasMore: false);

const _categories = <ExploreCategory>[
  ExploreCategory(id: 4, name: 'مقاهي'),
  ExploreCategory(id: 5, name: 'مطاعم'),
];

const _edit = VendorProductEdit(categoryId: 4, nameAr: 'قهوة', price: 1200);

final _photo = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'coffee.png',
);

void main() {
  late _MockVendorProductRemoteDataSource remote;
  late VendorProductRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_photo);
    registerFallbackValue(_edit);
    registerFallbackValue(const VendorProductQuery(locale: 'en'));
  });

  setUp(() {
    remote = _MockVendorProductRemoteDataSource();
    repository = VendorProductRepositoryImpl(remote);
  });

  test('the categories the endpoint answers are passed through', () async {
    when(
      () => remote.categories(locale: 'ar', query: 'مشروب'),
    ).thenAnswer((_) async => _categories);

    final result = await repository.categories(locale: 'ar', query: 'مشروب');

    expect((result as Success).value, _categories);
    verify(() => remote.categories(locale: 'ar', query: 'مشروب')).called(1);
  });

  test(
    'a page of products keeps what the listing says about the rest',
    () async {
      when(() => remote.products(any())).thenAnswer((_) async => _page);

      final result = await repository.products(
        const VendorProductQuery(locale: 'ar'),
      );

      final page = (result as Success).value;
      expect(page.products, const [_coffee]);
      expect(page.hasMore, isTrue);
      expect(page.nextPage, 2);
      expect(page.count, 41);
    },
  );

  test('the words and filters reach the request untouched', () async {
    when(() => remote.products(any())).thenAnswer((_) async => _emptyPage);
    const query = VendorProductQuery(
      locale: 'en',
      page: 2,
      categoryId: 4,
      status: VendorProductStatus.pending,
      text: 'coffee',
    );

    await repository.products(query);

    verify(() => remote.products(query)).called(1);
  });

  test('adding hands the fields and the picture to the endpoint', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: 'ar',
      ),
    ).thenAnswer((_) async => _coffee);

    final result = await repository.add(
      edit: _edit,
      image: _photo,
      locale: 'ar',
    );

    expect((result as Success).value.id, 3);
    verify(
      () => remote.add(edit: _edit, image: _photo, locale: 'ar'),
    ).called(1);
  });

  test('editing names the product it rewrote', () async {
    when(
      () => remote.update(
        id: any(named: 'id'),
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: 'en',
      ),
    ).thenAnswer((_) async => _juice);

    final result = await repository.update(id: 7, edit: _edit, locale: 'en');

    expect((result as Success).value.isApproved, isTrue);
    verify(
      () => remote.update(id: 7, edit: _edit, image: null, locale: 'en'),
    ).called(1);
  });

  test('a deleted product leaves nothing to show', () async {
    when(
      () => remote.remove(id: 7, locale: 'en'),
    ).thenAnswer((_) async => Future<void>.value());

    final result = await repository.remove(id: 7, locale: 'en');

    expect((result as Success).value, isNull);
  });

  test('a refused write becomes the failure the page shows', () async {
    when(
      () => remote.add(
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(const ServerException('The price must be a number.'));

    final result = await repository.add(edit: _edit, locale: 'en');

    final failure = (result as FailureResult).failure;
    expect(failure.message, 'The price must be a number.');
    expect(failure, isA<ServerFailure>());
  });

  test(
    'a listing that will not parse is a failure, not an empty page',
    () async {
      when(
        () => remote.products(any()),
      ).thenThrow(const ParseException('Product list reply carried no rows'));

      final result = await repository.products(
        const VendorProductQuery(locale: 'en'),
      );

      expect((result as FailureResult).failure, isA<ParsingFailure>());
    },
  );

  test('a listing that will not load is a network failure', () async {
    when(() => remote.products(any())).thenThrow(const NetworkException());

    final result = await repository.products(
      const VendorProductQuery(locale: 'en'),
    );

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('a deletion the server refused keeps its own sentence', () async {
    when(
      () => remote.remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    ).thenThrow(const ServerException('HTTP 403'));

    final result = await repository.remove(id: 7, locale: 'en');

    expect((result as FailureResult).failure.message, 'HTTP 403');
  });
}
