import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_search_query.dart';
import 'package:dali_alsham/features/services/domain/entities/service_sort.dart';
import 'package:dali_alsham/features/services/domain/entities/service_summary.dart';
import 'package:dali_alsham/features/services/domain/usecases/search_services.dart';
import 'package:dali_alsham/features/services/presentation/cubit/services_search_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockSearchServices extends Mock implements SearchServices {}

const _alAsad = ServiceSummary(id: 5, name: 'الاسد', rating: 4.9);
const _cafe = ServiceSummary(id: 8, name: 'البيروتي', rating: 4.1);

void main() {
  late _MockSearchServices search;
  late ServicesSearchCubit cubit;

  setUpAll(
    () => registerFallbackValue(
      const ServiceSearchQuery(text: 'الاسد', locale: 'ar'),
    ),
  );

  setUp(() {
    search = _MockSearchServices();
    cubit = ServicesSearchCubit(search);
  });

  tearDown(() => cubit.close());

  void answers(List<ServiceSummary> services, {bool hasMore = false}) {
    when(() => search.call(any())).thenAnswer(
      (_) async => Success(
        ServicePage(services: services, hasMore: hasMore, nextPage: 2),
      ),
    );
  }

  List<ServiceSearchQuery> requests() => verify(
    () => search.call(captureAny()),
  ).captured.cast<ServiceSearchQuery>();

  test('sends the words with the language and the gate', () async {
    answers([_alAsad]);

    await cubit.search(
      ' الاسد ',
      locale: 'ar',
      authenticated: true,
      userLat: 33.5,
      userLng: 36.28,
    );

    final query = requests().single;
    expect(query.text, 'الاسد');
    expect(query.locale, 'ar');
    expect(query.authenticated, isTrue);
    expect(query.userLat, 33.5);
    expect(query.page, 1);
    expect(cubit.state.status, ServicesSearchStatus.ready);
    expect(cubit.state.results, [_alAsad]);
  });

  test('an empty field asks the backend for nothing', () async {
    answers([_alAsad]);

    await cubit.search('   ', locale: 'ar', authenticated: false);

    verifyNever(() => search.call(any()));
    expect(cubit.state.status, ServicesSearchStatus.initial);
  });

  test('a chosen category narrows the words still in the field', () async {
    answers([_alAsad]);
    await cubit.search('الاسد', locale: 'ar', authenticated: false);

    await cubit.chooseCategory(4, 'مطاعم');

    final query = requests().last;
    expect(query.text, 'الاسد');
    expect(query.categoryId, 4);
    expect(query.page, 1);
    expect(cubit.state.categoryName, 'مطاعم');
    expect(cubit.state.hasFilters, isTrue);
  });

  test(
    'the order and the minimum rating travel as the endpoint spells them',
    () async {
      answers([_alAsad]);
      await cubit.search('الاسد', locale: 'ar', authenticated: false);

      await cubit.chooseSort(ServiceSort.distance);
      await cubit.chooseMinRating(4.5);

      final query = requests().last;
      expect(query.sort, ServiceSort.distance);
      expect(query.minRating, 4.5);
      expect(cubit.state.minRating, 4.5);
    },
  );

  test('a rating of zero is a chosen rating', () async {
    answers([_alAsad]);
    await cubit.search('الاسد', locale: 'ar', authenticated: false);

    await cubit.chooseMinRating(0);

    expect(requests().last.minRating, 0);
    expect(cubit.state.hasFilters, isTrue);
  });

  test('any rating is the filter cleared', () async {
    answers([_alAsad]);
    await cubit.search('الاسد', locale: 'ar', authenticated: false);
    await cubit.chooseMinRating(4);

    await cubit.chooseMinRating(null);

    expect(requests().last.minRating, isNull);
  });

  test('clearing the filters keeps the words and searches again', () async {
    answers([_alAsad]);
    await cubit.search('الاسد', locale: 'ar', authenticated: false);
    await cubit.chooseCategory(4, 'مطاعم');
    await cubit.chooseRegion(1, 'المزة');

    await cubit.clearFilters();

    final query = requests().last;
    expect(query.text, 'الاسد');
    expect(query.categoryId, isNull);
    expect(query.regionId, isNull);
    expect(cubit.state.hasFilters, isFalse);
  });

  test('the next page lands below what is already on screen', () async {
    answers([_alAsad], hasMore: true);
    await cubit.search('الاسد', locale: 'ar', authenticated: false);
    expect(cubit.state.hasMore, isTrue);

    answers([_cafe]);
    await cubit.loadMore();

    expect(requests().last.page, 2);
    expect(cubit.state.results, [_alAsad, _cafe]);
  });

  test('a search that will not arrive leaves the words for a retry', () async {
    when(
      () => search.call(any()),
    ).thenAnswer((_) async => const FailureResult(NetworkFailure()));

    await cubit.search('الاسد', locale: 'ar', authenticated: false);

    expect(cubit.state.status, ServicesSearchStatus.failure);
    expect(cubit.state.text, 'الاسد');
    expect(cubit.state.results, isEmpty);
  });

  test('a page that will not arrive keeps the results already read', () async {
    answers([_alAsad], hasMore: true);
    await cubit.search('الاسد', locale: 'ar', authenticated: false);

    when(
      () => search.call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));
    await cubit.loadMore();

    expect(cubit.state.status, ServicesSearchStatus.ready);
    expect(cubit.state.results, [_alAsad]);
    expect(cubit.state.isLoadingMore, isFalse);
  });
}
