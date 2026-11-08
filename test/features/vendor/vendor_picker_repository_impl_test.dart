import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/vendor/data/datasources/vendor_picker_remote_datasource.dart';
import 'package:dali_alsham/features/vendor/data/repositories/vendor_picker_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockVendorPickerRemoteDataSource extends Mock
    implements VendorPickerRemoteDataSource {}

const _region = Region(id: 1, name: 'المزة');

const _category = ExploreCategory(id: 4, name: 'مطاعم');

void main() {
  late _MockVendorPickerRemoteDataSource remote;
  late VendorPickerRepositoryImpl repository;

  setUp(() {
    remote = _MockVendorPickerRemoteDataSource();
    repository = VendorPickerRepositoryImpl(remote);
  });

  test(
    'a region list passes through with the language and the search',
    () async {
      when(
        () => remote.regions(locale: 'ar', query: 'مزة'),
      ).thenAnswer((_) async => const [_region]);

      final result = await repository.regions(locale: 'ar', query: 'مزة');

      expect((result as Success<List<Region>>).value, const [_region]);
      verify(() => remote.regions(locale: 'ar', query: 'مزة')).called(1);
    },
  );

  test('a category list passes through', () async {
    when(
      () => remote.categories(locale: 'en', query: null),
    ).thenAnswer((_) async => const [_category]);

    final result = await repository.categories(locale: 'en');

    expect((result as Success<List<ExploreCategory>>).value, const [_category]);
  });

  test('a refusal becomes the failure the form shows', () async {
    when(
      () => remote.regions(
        locale: any(named: 'locale'),
        query: any(named: 'query'),
      ),
    ).thenThrow(const ServerException('Auth failed'));

    final result = await repository.regions(locale: 'ar');

    expect(
      (result as FailureResult<List<Region>>).failure,
      const ServerFailure('Auth failed'),
    );
  });

  test('an offline search is a network failure', () async {
    when(
      () => remote.categories(
        locale: any(named: 'locale'),
        query: any(named: 'query'),
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.categories(locale: 'ar', query: 'م');

    expect((result as FailureResult).failure, isA<NetworkFailure>());
  });

  test('an unparsable reply is a parsing failure', () async {
    when(
      () => remote.regions(
        locale: any(named: 'locale'),
        query: any(named: 'query'),
      ),
    ).thenThrow(const ParseException('Pick list reply carried no list'));

    final result = await repository.regions(locale: 'ar');

    expect((result as FailureResult).failure, isA<ParsingFailure>());
  });

  test('a timeout stays a timeout failure', () async {
    when(
      () => remote.categories(
        locale: any(named: 'locale'),
        query: any(named: 'query'),
      ),
    ).thenThrow(const TimeoutException());

    final result = await repository.categories(locale: 'ar');

    expect((result as FailureResult).failure, isA<TimeoutFailure>());
  });
}
