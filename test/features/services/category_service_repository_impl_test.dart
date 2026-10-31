import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/services/data/datasources/category_service_remote_datasource.dart';
import 'package:dali_alsham/features/services/data/models/category_service_model.dart';
import 'package:dali_alsham/features/services/data/repositories/category_service_repository_impl.dart';
import 'package:dali_alsham/features/services/domain/entities/category_service_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryServiceRemoteDataSource extends Mock
    implements CategoryServiceRemoteDataSource {}

void main() {
  late _MockCategoryServiceRemoteDataSource remote;
  late CategoryServiceRepositoryImpl repository;

  setUp(() {
    remote = _MockCategoryServiceRemoteDataSource();
    repository = CategoryServiceRepositoryImpl(remote);
  });

  test('forwards the category, locale, page and location', () async {
    when(
      () => remote.fetchServices(
        categoryId: any(named: 'categoryId'),
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        userLat: any(named: 'userLat'),
        userLng: any(named: 'userLng'),
      ),
    ).thenAnswer(
      (_) async => const CategoryServicePage(services: [], hasMore: false),
    );

    await repository.getServices(
      categoryId: 7,
      locale: 'ar',
      page: 3,
      userLat: 33.51,
      userLng: 36.29,
    );

    verify(
      () => remote.fetchServices(
        categoryId: 7,
        locale: 'ar',
        page: 3,
        userLat: 33.51,
        userLng: 36.29,
      ),
    ).called(1);
  });

  test('defaults to the first page without a location', () async {
    when(
      () => remote.fetchServices(
        categoryId: any(named: 'categoryId'),
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        userLat: any(named: 'userLat'),
        userLng: any(named: 'userLng'),
      ),
    ).thenAnswer(
      (_) async => const CategoryServicePage(services: [], hasMore: false),
    );

    await repository.getServices(categoryId: 1, locale: 'en');

    verify(
      () => remote.fetchServices(
        categoryId: 1,
        locale: 'en',
        page: 1,
        userLat: null,
        userLng: null,
      ),
    ).called(1);
  });

  test('maps datasource errors to failures', () async {
    when(
      () => remote.fetchServices(
        categoryId: any(named: 'categoryId'),
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        userLat: any(named: 'userLat'),
        userLng: any(named: 'userLng'),
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.getServices(categoryId: 1, locale: 'en');

    expect(result, isA<FailureResult<CategoryServicePage>>());
    expect(
      (result as FailureResult<CategoryServicePage>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('rejects a service payload without a usable name', () {
    expect(
      () => CategoryServiceModel.fromJson(const {'id': 3, 'name': '   '}),
      throwsFormatException,
    );
  });

  test('keeps a service without optional fields', () {
    final service = CategoryServiceModel.fromJson(const {
      'id': 1,
      'name': 'الاسد',
    });

    expect(service.regionName, isNull);
    expect(service.address, isNull);
    expect(service.rating, 0);
    expect(service.reviewsCount, 0);
    expect(service.distanceText, isNull);
    expect(service.imageUrl, isNull);
  });
}
