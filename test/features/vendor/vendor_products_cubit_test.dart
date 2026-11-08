import 'dart:async';
import 'dart:typed_data';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/profile/domain/entities/avatar_file.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_edit.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_page.dart';
import 'package:dali_alsham/features/vendor/domain/entities/vendor_product_query.dart';
import 'package:dali_alsham/features/vendor/domain/repositories/vendor_product_repository.dart';
import 'package:dali_alsham/features/vendor/presentation/cubit/vendor_products_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorProductRepository extends Mock
    implements VendorProductRepository {}

const _coffee = VendorProduct(
  id: 3,
  nameAr: 'قهوة',
  nameEn: 'Coffee',
  categoryName: 'مقاهي',
  price: 1200,
  quantity: 4,
);

const _juice = VendorProduct(
  id: 7,
  nameAr: 'عصير',
  price: 9000,
  isApproved: true,
);

const _firstPage = VendorProductPage(
  products: [_coffee],
  hasMore: true,
  nextPage: 2,
  count: 21,
);

const _secondPage = VendorProductPage(
  products: [_juice],
  hasMore: false,
  count: 21,
);

const _emptyPage = VendorProductPage(products: [], hasMore: false);

const _edit = VendorProductEdit(categoryId: 4, nameAr: 'قهوة', price: 1200);

final _photo = AvatarFile(
  bytes: Uint8List.fromList([1, 2, 3]),
  fileName: 'coffee.png',
);

/// The listing is asked for once per filter change, so a test that wants the
/// words sent reads the most recent request off the log.
final _requests = <VendorProductQuery>[];

void main() {
  late _MockVendorProductRepository repository;
  late VendorProductsCubit cubit;

  setUpAll(() {
    registerFallbackValue(_photo);
    registerFallbackValue(_edit);
    registerFallbackValue(const VendorProductQuery(locale: 'en'));
  });

  setUp(() {
    repository = _MockVendorProductRepository();
    cubit = VendorProductsCubit(repository);
    _requests.clear();

    when(() => repository.products(any())).thenAnswer((invocation) async {
      _requests.add(
        invocation.positionalArguments.single as VendorProductQuery,
      );
      return const Success(_firstPage);
    });
    when(
      () => repository.add(
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_coffee));
    when(
      () => repository.update(
        id: any(named: 'id'),
        edit: any(named: 'edit'),
        image: any(named: 'image'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success(_coffee));
    when(
      () => repository.remove(
        id: any(named: 'id'),
        locale: any(named: 'locale'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));
  });

  tearDown(() async => cubit.close());

  test(
    'the first read fills the list and keeps the count it was given',
    () async {
      await cubit.load('ar');

      expect(cubit.state.status, VendorProductsStatus.ready);
      expect(cubit.state.products, const [_coffee]);
      expect(cubit.state.count, 21);
      expect(cubit.state.hasMore, isTrue);
      expect(_requests.single.locale, 'ar');
    },
  );

  test('a listing that will not load leaves the page a retry', () async {
    when(
      () => repository.products(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await cubit.load('en');

    expect(cubit.state.status, VendorProductsStatus.failure);
    expect(cubit.state.products, isEmpty);
  });

  test(
    'the words typed go out as q and empty words ask for the whole list',
    () async {
      await cubit.load('en');
      await cubit.search('قهوة');

      expect(_requests.last.text, 'قهوة');
      expect(cubit.state.text, 'قهوة');

      await cubit.search('   ');

      expect(_requests.last.text, '');
      expect(cubit.state.text, '');
    },
  );

  test('the same words typed twice do not read the listing again', () async {
    await cubit.load('en');
    await cubit.search('coffee');
    final reads = _requests.length;
    await cubit.search('coffee');

    expect(_requests, hasLength(reads));
  });

  test(
    'choosing a category narrows the next read and labels the chip',
    () async {
      await cubit.load('en');
      await cubit.chooseCategory(id: 4, name: 'مقاهي');

      expect(cubit.state.categoryId, 4);
      expect(cubit.state.categoryName, 'مقاهي');
      expect(_requests.last.categoryId, 4);
      expect(cubit.state.hasFilters, isTrue);
    },
  );

  test('the same category chosen twice leaves the list alone', () async {
    await cubit.load('en');
    await cubit.chooseCategory(id: 4, name: 'مقاهي');
    final reads = _requests.length;
    await cubit.chooseCategory(id: 4, name: 'مقاهي');

    expect(_requests, hasLength(reads));
  });

  test(
    'the approval state travels as the status the endpoint spells',
    () async {
      await cubit.load('en');
      await cubit.chooseApproval(VendorProductStatus.pending);

      expect(_requests.last.status, VendorProductStatus.pending);

      await cubit.chooseApproval(VendorProductStatus.approved);

      expect(_requests.last.status, VendorProductStatus.approved);
      expect(cubit.state.approval, VendorProductStatus.approved);
    },
  );

  test('any status means no status sent at all', () async {
    await cubit.load('en');
    await cubit.chooseApproval(VendorProductStatus.rejected);
    await cubit.chooseApproval(null);

    expect(cubit.state.approval, isNull);
    expect(_requests.last.status, isNull);
  });

  test(
    'clearing takes the words, the category and the state off together',
    () async {
      await cubit.load('en');
      await cubit.chooseCategory(id: 4, name: 'مقاهي');
      await cubit.chooseApproval(VendorProductStatus.pending);
      await cubit.search('قهوة');

      await cubit.clearFilters();

      expect(cubit.state.hasFilters, isFalse);
      expect(cubit.state.text, '');
      expect(cubit.state.categoryId, isNull);
      expect(cubit.state.categoryName, isNull);
      expect(cubit.state.approval, isNull);
      expect(_requests.last, const VendorProductQuery(locale: 'en'));
    },
  );

  test(
    'a filter change reads the first page again, not the one it was on',
    () async {
      await cubit.load('en');
      await cubit.loadMore();
      await cubit.search('coffee');

      expect(_requests.last.page, 1);
      // The appended second page is gone with it.
      expect(cubit.state.products, const [_coffee]);
    },
  );

  test(
    'load more appends the next page and stops when there is none',
    () async {
      when(() => repository.products(any())).thenAnswer((invocation) async {
        _requests.add(
          invocation.positionalArguments.single as VendorProductQuery,
        );
        final query = _requests.last;
        return Success(query.page > 1 ? _secondPage : _firstPage);
      });

      await cubit.load('en');
      await cubit.loadMore();

      expect(cubit.state.products, const [_coffee, _juice]);
      expect(_requests.last.page, 2);
      expect(cubit.state.hasMore, isFalse);

      final reads = _requests.length;
      await cubit.loadMore();

      expect(_requests, hasLength(reads));
    },
  );

  test('a page that fails to append keeps the rows already shown', () async {
    when(() => repository.products(any())).thenAnswer((invocation) async {
      _requests.add(
        invocation.positionalArguments.single as VendorProductQuery,
      );
      return _requests.last.page > 1
          ? const FailureResult(ServerFailure())
          : const Success(_firstPage);
    });

    await cubit.load('en');
    await cubit.loadMore();

    expect(cubit.state.status, VendorProductsStatus.ready);
    expect(cubit.state.products, const [_coffee]);
    expect(cubit.state.isLoadingMore, isFalse);
  });

  test('adding writes, then reads the first page back', () async {
    await cubit.load('en');
    when(
      () => repository.products(any()),
    ).thenAnswer((_) async => const Success(_emptyPage));

    expect(await cubit.add(edit: _edit, image: _photo), isNull);

    verify(
      () => repository.add(edit: _edit, image: _photo, locale: 'en'),
    ).called(1);
    // Once for the page that opened, once for the read after the write.
    verify(() => repository.products(any())).called(2);
    expect(cubit.state.products, isEmpty);
    expect(cubit.state.isBusy, isFalse);
  });

  test('editing sends the id the list was read with', () async {
    await cubit.load('ar');
    await cubit.update(id: 7, edit: _edit);

    verify(
      () => repository.update(id: 7, edit: _edit, image: null, locale: 'ar'),
    ).called(1);
  });

  test('deleting names the product and re-reads what is left', () async {
    await cubit.load('en');

    expect(await cubit.remove(id: 3), isNull);

    verify(() => repository.remove(id: 3, locale: 'en')).called(1);
    verify(() => repository.products(any())).called(2);
  });

  test('a write uses the language the list was loaded in', () async {
    await cubit.load('ar');
    await cubit.remove(id: 3);

    verify(() => repository.remove(id: 3, locale: 'ar')).called(1);
  });

  test(
    'a refused write answers with the backend sentence and reads nothing',
    () async {
      await cubit.load('en');
      when(
        () => repository.add(
          edit: any(named: 'edit'),
          image: any(named: 'image'),
          locale: any(named: 'locale'),
        ),
      ).thenAnswer(
        (_) async =>
            const FailureResult(ServerFailure('The price must be a number.')),
      );

      expect(
        await cubit.add(edit: _edit, image: _photo),
        'The price must be a number.',
      );

      // The rows on screen stay until the server says otherwise.
      expect(cubit.state.products, const [_coffee]);
      expect(cubit.state.isBusy, isFalse);
      verify(() => repository.products(any())).called(1);
    },
  );

  test(
    'a write in flight keeps the page busy until the server answers',
    () async {
      await cubit.load('en');
      final held = Completer<Result<VendorProduct>>();
      when(
        () => repository.add(
          edit: any(named: 'edit'),
          image: any(named: 'image'),
          locale: any(named: 'locale'),
        ),
      ).thenAnswer((_) => held.future);

      final first = cubit.add(edit: _edit);
      await Future<void>(() {});

      expect(cubit.state.isBusy, isTrue);

      held.complete(const Success(_coffee));
      expect(await first, isNull);
      expect(cubit.state.isBusy, isFalse);
    },
  );
}
