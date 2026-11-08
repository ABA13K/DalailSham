import 'dart:async';

import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/entities/service_summary.dart';
import 'package:dali_alsham/features/services/domain/usecases/get_service_page.dart';
import 'package:dali_alsham/features/services/presentation/cubit/services_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetServicePage extends Mock implements GetServicePage {}

ServicePageParams _singleRequest(GetServicePage usecase) =>
    verify(() => usecase.call(captureAny())).captured.single
        as ServicePageParams;

ServiceSummary _shop(int id) => ServiceSummary(id: id, name: 'Shop $id');

void main() {
  late _MockGetServicePage getServicePage;
  late ServicesCubit cubit;

  setUpAll(
    () => registerFallbackValue(
      const ServicePageParams(scope: ServiceScope.nearby, locale: 'en'),
    ),
  );

  setUp(() {
    getServicePage = _MockGetServicePage();
    cubit = ServicesCubit(getServicePage);
  });

  tearDown(() => cubit.close());

  test('a category listing asks its own endpoint page', () async {
    when(() => getServicePage.call(any())).thenAnswer(
      (_) async => Success(
        ServicePage(services: [_shop(1)], hasMore: true, nextPage: 2),
      ),
    );

    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'ar');

    final params = _singleRequest(getServicePage);
    expect(params.scope, ServiceScope.category);
    expect(params.scopeId, 7);
    expect(params.locale, 'ar');
    expect(params.page, 1);
    expect(cubit.state.status, ServicesStatus.ready);
    expect(cubit.state.services, [_shop(1)]);
    expect(cubit.state.hasMore, isTrue);
  });

  test('load more asks for the next page and appends to the rows', () async {
    var calls = 0;
    when(() => getServicePage.call(any())).thenAnswer((invocation) async {
      final params = invocation.positionalArguments.single as ServicePageParams;
      calls++;
      return Success(
        ServicePage(
          services: [_shop(params.page)],
          hasMore: params.page == 1,
          nextPage: params.page == 1 ? 2 : null,
        ),
      );
    });

    await cubit.load(scope: ServiceScope.nearby, locale: 'en');
    await cubit.loadMore();

    expect(calls, 2);
    expect(cubit.state.services, [_shop(1), _shop(2)]);
    expect(cubit.state.hasMore, isFalse);
    expect(cubit.state.isLoadingMore, isFalse);
  });

  test('a listing with no page after it is not asked for more', () async {
    var calls = 0;
    when(() => getServicePage.call(any())).thenAnswer((_) async {
      calls++;
      return Success(ServicePage(services: [_shop(1)], hasMore: false));
    });

    await cubit.load(scope: ServiceScope.region, scopeId: 3, locale: 'en');
    await cubit.loadMore();

    expect(calls, 1);
    expect(cubit.state.services, [_shop(1)]);
  });

  test('the newest choice wins when an older listing arrives last', () async {
    final stale = Completer<Result<ServicePage>>();
    var calls = 0;
    when(() => getServicePage.call(any())).thenAnswer((invocation) {
      final params = invocation.positionalArguments.single as ServicePageParams;
      calls++;
      return calls == 1
          ? stale.future
          : Future.value(
              Success(
                ServicePage(
                  services: [_shop(params.scopeId ?? 0)],
                  hasMore: false,
                ),
              ),
            );
    });

    final first = cubit.load(
      scope: ServiceScope.category,
      scopeId: 1,
      locale: 'en',
    );
    await cubit.load(scope: ServiceScope.category, scopeId: 2, locale: 'en');
    stale.complete(Success(ServicePage(services: [_shop(99)], hasMore: false)));
    await first;

    expect(cubit.state.services, [_shop(2)]);
    expect(cubit.state.status, ServicesStatus.ready);
  });

  test('a failed listing keeps the message for the page to show', () async {
    when(
      () => getServicePage.call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await cubit.load(scope: ServiceScope.nearby, locale: 'en');

    expect(cubit.state.status, ServicesStatus.failure);
    expect(cubit.state.services, isEmpty);
  });

  test('a refresh of the same choice keeps its rows instead of blanking them', () async {
    var calls = 0;
    when(() => getServicePage.call(any())).thenAnswer((_) async {
      calls++;
      return Success(ServicePage(services: [_shop(calls)], hasMore: false));
    });

    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'en');
    final seen = <ServicesStatus>[];
    final watching = cubit.stream.listen((state) => seen.add(state.status));
    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'en');
    await Future<void>.delayed(Duration.zero);
    await watching.cancel();

    // The page moved from the first set to the second with no placeholder in
    // between, so the list is rebuilt once, on its own new rows.
    expect(seen, isNot(contains(ServicesStatus.loading)));
    expect(cubit.state.services, [_shop(2)]);
  });

  test('a refresh that brings the same rows is the same state', () async {
    when(() => getServicePage.call(any())).thenAnswer(
      (_) async => Success(ServicePage(services: [_shop(1)], hasMore: false)),
    );

    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'en');
    final shown = cubit.state;
    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'en');

    // Nothing of this section changed, so nothing of it is rebuilt.
    expect(cubit.state, shown);
  });

  test('a failed refresh leaves the rows the reader is looking at', () async {
    var calls = 0;
    when(() => getServicePage.call(any())).thenAnswer((_) async {
      calls++;
      return calls == 1
          ? Success(ServicePage(services: [_shop(1)], hasMore: false))
          : const FailureResult(ServerFailure());
    });

    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'en');
    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'en');

    expect(cubit.state.status, ServicesStatus.ready);
    expect(cubit.state.services, [_shop(1)]);
  });

  test('another choice is a new list, so its rows start empty', () async {
    var calls = 0;
    when(() => getServicePage.call(any())).thenAnswer((_) async {
      calls++;
      return Success(ServicePage(services: [_shop(calls)], hasMore: false));
    });

    await cubit.load(scope: ServiceScope.category, scopeId: 7, locale: 'en');
    final seen = <ServicesStatus>[];
    final watching = cubit.stream.listen((state) => seen.add(state.status));
    await cubit.load(scope: ServiceScope.category, scopeId: 8, locale: 'en');
    await Future<void>.delayed(Duration.zero);
    await watching.cancel();

    // The pill the reader pressed names a different set, so a placeholder is
    // what belongs on screen while it arrives.
    expect(seen, contains(ServicesStatus.loading));
    expect(cubit.state.services, [_shop(2)]);
  });
}
