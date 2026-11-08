import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/banners/domain/entities/banner_ad.dart';
import 'package:dali_alsham/features/banners/domain/usecases/get_banners.dart';
import 'package:dali_alsham/features/banners/presentation/cubit/banners_cubit.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:dali_alsham/features/categories/domain/usecases/get_random_categories.dart';
import 'package:dali_alsham/features/categories/presentation/cubit/categories_cubit.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/regions/domain/usecases/get_random_regions.dart';
import 'package:dali_alsham/features/regions/presentation/cubit/regions_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetRandomCategories extends Mock implements GetRandomCategories {}

class _MockGetRandomRegions extends Mock implements GetRandomRegions {}

class _MockGetBanners extends Mock implements GetBanners {}

const _categories = [ExploreCategory(id: 1, name: 'Shawarma Streets')];
const _regions = [Region(id: 4, name: 'Barzeh')];
const _banners = [BannerAd(id: 7, text: 'Dali Alsham')];

void main() {
  setUpAll(() {
    registerFallbackValue(const RandomCategoriesParams(locale: 'en'));
    registerFallbackValue(const RandomRegionsParams(locale: 'en'));
  });

  group('CategoriesCubit', () {
    late _MockGetRandomCategories usecase;
    late CategoriesCubit cubit;

    setUp(() {
      usecase = _MockGetRandomCategories();
      cubit = CategoriesCubit(usecase);
      when(
        () => usecase.call(any()),
      ).thenAnswer((_) async => const Success(_categories));
    });

    tearDown(() => cubit.close());

    test('a refresh over identical categories changes nothing', () async {
      final states = <CategoriesState>[];
      cubit.stream.listen(states.add);

      await cubit.load('en');
      await cubit.load('en');
      await pumpEventQueue();

      expect(states, [
        isA<CategoriesLoading>(),
        isA<CategoriesReady>(),
      ], reason: 'the second load must not flash the placeholder');
    });

    test('a failed refresh keeps the showcase on screen', () async {
      await cubit.load('en');
      when(
        () => usecase.call(any()),
      ).thenAnswer((_) async => const FailureResult(ServerFailure()));

      await cubit.load('en');

      expect(cubit.state, const CategoriesReady(_categories));
    });

    test('a first load that fails still reports the error', () async {
      when(
        () => usecase.call(any()),
      ).thenAnswer((_) async => const FailureResult(ServerFailure()));

      await cubit.load('en');

      expect(cubit.state, isA<CategoriesError>());
    });
  });

  group('RegionsCubit', () {
    late _MockGetRandomRegions usecase;
    late RegionsCubit cubit;

    setUp(() {
      usecase = _MockGetRandomRegions();
      cubit = RegionsCubit(usecase);
      when(
        () => usecase.call(any()),
      ).thenAnswer((_) async => const Success(_regions));
    });

    tearDown(() => cubit.close());

    test('a refresh over identical regions changes nothing', () async {
      final states = <RegionsState>[];
      cubit.stream.listen(states.add);

      await cubit.load('en');
      await cubit.reload();
      await pumpEventQueue();

      expect(states, [
        isA<RegionsLoading>(),
        isA<RegionsReady>(),
      ], reason: 'the refresh must not flash the placeholder');
    });

    test('a failed refresh keeps the showcase on screen', () async {
      await cubit.load('en');
      when(
        () => usecase.call(any()),
      ).thenAnswer((_) async => const FailureResult(ServerFailure()));

      await cubit.reload();

      expect(cubit.state, const RegionsReady(_regions));
    });
  });

  group('BannersCubit', () {
    late _MockGetBanners usecase;
    late BannersCubit cubit;

    setUp(() {
      usecase = _MockGetBanners();
      cubit = BannersCubit(usecase);
      when(
        () => usecase.call(any()),
      ).thenAnswer((_) async => const Success(_banners));
    });

    tearDown(() => cubit.close());

    test('a refresh over identical banners changes nothing', () async {
      final states = <BannersState>[];
      cubit.stream.listen(states.add);

      await cubit.load('ar');
      await cubit.load('ar');
      await pumpEventQueue();

      expect(states, [
        isA<BannersLoading>(),
        isA<BannersReady>(),
      ], reason: 'the carousel must keep playing through a refresh');
    });

    test('a failed refresh keeps the banners on screen', () async {
      await cubit.load('ar');
      when(
        () => usecase.call(any()),
      ).thenAnswer((_) async => const FailureResult(ServerFailure()));

      await cubit.load('ar');

      expect(cubit.state, const BannersReady(_banners));
    });
  });
}
