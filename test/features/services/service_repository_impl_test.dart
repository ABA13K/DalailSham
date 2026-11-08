import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/services/data/datasources/service_remote_datasource.dart';
import 'package:dali_alsham/features/services/data/models/service_summary_model.dart';
import 'package:dali_alsham/features/services/data/repositories/service_repository_impl.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/entities/service_search_query.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockServiceRemoteDataSource extends Mock
    implements ServiceRemoteDataSource {}

void main() {
  late _MockServiceRemoteDataSource remote;
  late ServiceRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(ServiceScope.category);
    registerFallbackValue(
      const ServiceSearchQuery(text: 'الاسد', locale: 'ar'),
    );
  });

  setUp(() {
    remote = _MockServiceRemoteDataSource();
    repository = ServiceRepositoryImpl(remote);
  });

  void stubFetch() {
    when(
      () => remote.fetchServices(
        scope: any(named: 'scope'),
        scopeId: any(named: 'scopeId'),
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        userLat: any(named: 'userLat'),
        userLng: any(named: 'userLng'),
        authenticated: any(named: 'authenticated'),
      ),
    ).thenAnswer((_) async => const ServicePage(services: [], hasMore: false));
  }

  test('forwards the scope, locale, page and location', () async {
    stubFetch();

    await repository.getServices(
      scope: ServiceScope.region,
      scopeId: 7,
      locale: 'ar',
      page: 3,
      userLat: 33.51,
      userLng: 36.29,
      authenticated: true,
    );

    verify(
      () => remote.fetchServices(
        scope: ServiceScope.region,
        scopeId: 7,
        locale: 'ar',
        page: 3,
        userLat: 33.51,
        userLng: 36.29,
        authenticated: true,
      ),
    ).called(1);
  });

  test('forwards the first page without a location', () async {
    stubFetch();

    await repository.getServices(
      scope: ServiceScope.category,
      scopeId: 1,
      locale: 'en',
      page: 1,
    );

    verify(
      () => remote.fetchServices(
        scope: ServiceScope.category,
        scopeId: 1,
        locale: 'en',
        page: 1,
        userLat: null,
        userLng: null,
        authenticated: false,
      ),
    ).called(1);
  });

  test('maps datasource errors to failures', () async {
    when(
      () => remote.fetchServices(
        scope: any(named: 'scope'),
        scopeId: any(named: 'scopeId'),
        locale: any(named: 'locale'),
        page: any(named: 'page'),
        userLat: any(named: 'userLat'),
        userLng: any(named: 'userLng'),
        authenticated: any(named: 'authenticated'),
      ),
    ).thenThrow(const NetworkException());

    final result = await repository.getServices(
      scope: ServiceScope.category,
      scopeId: 1,
      locale: 'en',
      page: 1,
    );

    expect(result, isA<FailureResult<ServicePage>>());
    expect(
      (result as FailureResult<ServicePage>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('rejects a service payload without a usable name', () {
    expect(
      () => ServiceSummaryModel.fromJson(const {'id': 3, 'name': '   '}),
      throwsFormatException,
    );
  });

  test('keeps a service without optional fields', () {
    final service = ServiceSummaryModel.fromJson(const {
      'id': 1,
      'name': 'الاسد',
    });

    expect(service.regionName, isNull);
    expect(service.categoryName, isNull);
    expect(service.address, isNull);
    expect(service.rating, 0);
    expect(service.reviewsCount, 0);
    expect(service.distanceText, isNull);
    expect(service.imageUrl, isNull);
  });

  test('hands the search query to the datasource unchanged', () async {
    const query = ServiceSearchQuery(
      text: 'الاسد',
      locale: 'ar',
      categoryId: 1,
      minRating: 4,
    );
    when(
      () => remote.search(query),
    ).thenAnswer((_) async => const ServicePage(services: [], hasMore: false));

    final result = await repository.search(query);

    expect(result, isA<Success<ServicePage>>());
    verify(() => remote.search(query)).called(1);
  });

  test(
    'a search that will not arrive is a failure, not an empty list',
    () async {
      when(() => remote.search(any())).thenThrow(const TimeoutException());

      final result = await repository.search(
        const ServiceSearchQuery(text: 'الاسد', locale: 'ar'),
      );

      expect(result, isA<FailureResult<ServicePage>>());
      expect(
        (result as FailureResult<ServicePage>).failure,
        isA<TimeoutFailure>(),
      );
    },
  );
}
