import 'package:dali_alsham/core/error/exceptions.dart';
import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:dali_alsham/features/categories/data/models/explore_category_model.dart';
import 'package:dali_alsham/features/categories/data/repositories/category_repository_impl.dart';
import 'package:dali_alsham/features/categories/domain/entities/category_page.dart';
import 'package:dali_alsham/features/categories/domain/entities/explore_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryRemoteDataSource extends Mock
    implements CategoryRemoteDataSource {}

void main() {
  late _MockCategoryRemoteDataSource remote;

  setUp(() {
    remote = _MockCategoryRemoteDataSource();
  });

  test('fills the random rail from the full list up to the limit', () async {
    when(
      () => remote.fetchRandomCategories(locale: any(named: 'locale')),
    ).thenAnswer(
      (_) async => const [ExploreCategoryModel(id: 1, name: 'Restaurants')],
    );
    when(
      () => remote.fetchCategories(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
      ),
    ).thenAnswer(
      (_) async => const CategoryPage(
        categories: [
          ExploreCategory(id: 1, name: 'Restaurants'),
          ExploreCategory(id: 2, name: 'Cafés'),
          ExploreCategory(id: 3, name: 'Hotels'),
        ],
        hasMore: false,
      ),
    );

    final result = await CategoryRepositoryImpl(
      remote,
    ).getRandomCategories(locale: 'en', limit: 3);

    final categories = (result as Success<List<ExploreCategory>>).value;
    expect(categories.first.id, 1);
    expect(categories.map((category) => category.id).toSet(), {1, 2, 3});
  });

  test('keeps the random result when the fill request fails', () async {
    when(
      () => remote.fetchRandomCategories(locale: any(named: 'locale')),
    ).thenAnswer(
      (_) async => const [ExploreCategoryModel(id: 1, name: 'Restaurants')],
    );
    when(
      () => remote.fetchCategories(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
      ),
    ).thenThrow(const NetworkException());

    final result = await CategoryRepositoryImpl(
      remote,
    ).getRandomCategories(locale: 'en', limit: 8);

    expect(result, isA<Success<List<ExploreCategory>>>());
    expect((result as Success<List<ExploreCategory>>).value, hasLength(1));
  });

  test('maps datasource errors to failures', () async {
    when(
      () => remote.fetchCategories(
        locale: any(named: 'locale'),
        page: any(named: 'page'),
      ),
    ).thenThrow(const NetworkException());

    final result = await CategoryRepositoryImpl(
      remote,
    ).getCategories(locale: 'en');

    expect(result, isA<FailureResult<CategoryPage>>());
    expect(
      (result as FailureResult<CategoryPage>).failure,
      isA<NetworkFailure>(),
    );
  });

  test('rewrites localhost image origins to the public host', () {
    final category = ExploreCategoryModel.fromJson(<String, dynamic>{
      'id': 1,
      'name': 'Restaurants',
      'image': 'http://127.0.0.1:8000/storage/categories/x.png',
      'inspirational_phrase': 'Discover the most delicious dishes',
    });

    expect(
      category.imageUrl,
      'https://dalildimashq.com/storage/categories/x.png',
    );
    expect(category.tagline, 'Discover the most delicious dishes');
  });
}
