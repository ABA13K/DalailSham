import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/entities/service_summary.dart';
import 'package:dali_alsham/features/services/domain/usecases/get_service_page.dart';
import 'package:dali_alsham/features/services/presentation/cubit/services_cubit.dart';
import 'package:dali_alsham/features/services/presentation/cubit/top_rated_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetServicePage extends Mock implements GetServicePage {}

const _alAsad = ServiceSummary(id: 5, name: 'Al Asad', rating: 4.9);

ServicePageParams _singleRequest(GetServicePage usecase) =>
    verify(() => usecase.call(captureAny())).captured.single
        as ServicePageParams;

void main() {
  late _MockGetServicePage getServicePage;
  late TopRatedCubit cubit;

  setUpAll(
    () => registerFallbackValue(
      const ServicePageParams(scope: ServiceScope.topRated, locale: 'en'),
    ),
  );

  setUp(() {
    getServicePage = _MockGetServicePage();
    cubit = TopRatedCubit(getServicePage);
  });

  tearDown(() => cubit.close());

  test('loads the top-ten scope with the user location', () async {
    when(() => getServicePage.call(any())).thenAnswer(
      (_) async =>
          const Success(ServicePage(services: [_alAsad], hasMore: false)),
    );

    await cubit.load(
      locale: 'ar',
      authenticated: false,
      userLat: 33.5,
      userLng: 36.28,
    );

    final params = _singleRequest(getServicePage);
    expect(params.scope, ServiceScope.topRated);
    expect(params.scopeId, isNull);
    expect(params.locale, 'ar');
    expect(params.authenticated, isFalse);
    expect(params.userLat, 33.5);
    expect(cubit.state.status, ServicesStatus.ready);
    expect(cubit.state.services, [_alAsad]);
  });

  test('asks the signed-in endpoint when a token is stored', () async {
    when(() => getServicePage.call(any())).thenAnswer(
      (_) async => const Success(ServicePage(services: [], hasMore: false)),
    );

    await cubit.load(locale: 'en', authenticated: true);

    expect(_singleRequest(getServicePage).authenticated, isTrue);
  });

  test('keeps the failure so the rail can hide itself', () async {
    when(
      () => getServicePage.call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await cubit.load(locale: 'en', authenticated: false);

    expect(cubit.state.status, ServicesStatus.failure);
    expect(cubit.state.failure, isA<ServerFailure>());
    expect(cubit.state.services, isEmpty);
  });

  test('ignores an older response that arrives last', () async {
    final stale = Completer<Result<ServicePage>>();
    var calls = 0;
    when(() => getServicePage.call(any())).thenAnswer((_) {
      calls++;
      return calls == 1
          ? stale.future
          : Future.value(
              const Success(ServicePage(services: [], hasMore: false)),
            );
    });

    final pending = cubit.load(locale: 'en', authenticated: false);
    await cubit.load(locale: 'en', authenticated: true);

    stale.complete(
      const Success(ServicePage(services: [_alAsad], hasMore: false)),
    );
    await pending;

    expect(cubit.state.status, ServicesStatus.ready);
    expect(cubit.state.services, isEmpty);
  });

  test('a refresh over the same ten services changes nothing', () async {
    final states = <TopRatedState>[];
    cubit.stream.listen(states.add);
    when(() => getServicePage.call(any())).thenAnswer(
      (_) async =>
          const Success(ServicePage(services: [_alAsad], hasMore: false)),
    );

    await cubit.load(locale: 'en', authenticated: false);
    await cubit.load(locale: 'en', authenticated: false);
    await pumpEventQueue();

    expect(
      states.map((state) => state.status),
      [ServicesStatus.loading, ServicesStatus.ready],
      reason: 'the rail must not flash its placeholder on refresh',
    );
  });

  test('a failed refresh keeps the services already on screen', () async {
    when(() => getServicePage.call(any())).thenAnswer(
      (_) async =>
          const Success(ServicePage(services: [_alAsad], hasMore: false)),
    );
    await cubit.load(locale: 'en', authenticated: false);

    when(
      () => getServicePage.call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));
    await cubit.load(locale: 'en', authenticated: false);

    expect(cubit.state.status, ServicesStatus.ready);
    expect(cubit.state.services, [_alAsad]);
  });

  test(
    'a changed token refetches instead of reusing the signed-in list',
    () async {
      when(() => getServicePage.call(any())).thenAnswer(
        (_) async =>
            const Success(ServicePage(services: [_alAsad], hasMore: false)),
      );
      await cubit.load(locale: 'en', authenticated: true);

      final states = <TopRatedState>[];
      cubit.stream.listen(states.add);
      when(
        () => getServicePage.call(any()),
      ).thenAnswer((_) async => const FailureResult(ServerFailure()));
      await cubit.load(locale: 'en', authenticated: false);
      await pumpEventQueue();

      expect(states.map((state) => state.status), [
        ServicesStatus.loading,
        ServicesStatus.failure,
      ]);
    },
  );
}
