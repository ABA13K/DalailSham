import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/settings/domain/token_repository.dart';
import 'package:dali_alsham/core/settings/presentation/token_cubit.dart';
import 'package:dali_alsham/di/injection.dart';
import 'package:dali_alsham/features/favorites/domain/entities/favorite_mutation.dart';
import 'package:dali_alsham/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:dali_alsham/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:dali_alsham/features/location/domain/usecases/get_current_location.dart';
import 'package:dali_alsham/features/location/domain/usecases/has_location_access.dart';
import 'package:dali_alsham/features/location/presentation/location_cubit.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_detail.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_product.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_review.dart';
import 'package:dali_alsham/features/service_profile/domain/usecases/get_service_detail.dart';
import 'package:dali_alsham/features/service_profile/domain/usecases/get_service_images.dart';
import 'package:dali_alsham/features/service_profile/domain/usecases/get_service_product_categories.dart';
import 'package:dali_alsham/features/service_profile/domain/usecases/get_service_products.dart';
import 'package:dali_alsham/features/service_profile/domain/usecases/get_service_reviews.dart';
import 'package:dali_alsham/features/service_profile/presentation/pages/service_profile_page.dart';
import 'package:dali_alsham/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockGetServiceDetail extends Mock implements GetServiceDetail {}

class _MockGetServiceImages extends Mock implements GetServiceImages {}

class _MockGetServiceProducts extends Mock implements GetServiceProducts {}

class _MockGetServiceProductCategories extends Mock
    implements GetServiceProductCategories {}

class _MockGetServiceReviews extends Mock implements GetServiceReviews {}

class _MockTokenRepository extends Mock implements TokenRepository {}

class _MockGetCurrentLocation extends Mock implements GetCurrentLocation {}

class _MockHasLocationAccess extends Mock implements HasLocationAccess {}

class _MockFavoritesRepository extends Mock implements FavoritesRepository {}

const _detail = ServiceDetail(
  id: 1,
  name: 'الاسد',
  slug: 'amran',
  categoryName: 'مطاعم',
  regionName: 'المزة',
  address: 'دمشق',
  rating: 4.4,
  reviewsCount: 5,
  isFavorited: true,
  isAuthenticated: true,
  description: 'عمران',
  isOpenNow: true,
  visitsCount: 15,
  contacts: [
    ServiceContactGroup(
      type: 'phone',
      label: 'هاتف',
      values: [ServiceContactValue(value: '0999111222', isPrimary: true)],
    ),
  ],
  workingHours: [
    ServiceWorkingDay(
      day: 'السبت',
      openTime: '10:00:00',
      closeTime: '22:00:00',
    ),
  ],
  amenities: ['مكان صلاة111'],
  imagesCount: 3,
  productsCount: 1,
);

const _products = ServiceProductPage(
  products: [
    ServiceProduct(
      id: 2,
      name: 'قهوة عربي',
      description: 'قهوة عربية بالهيل',
      price: 1001,
      quantity: 10001,
      categorySlug: 'hot-drinks',
      categoryName: 'مشروبات ساخنة',
    ),
  ],
  hasMore: false,
  total: 1,
);

const _reviewPage = ServiceReviewPage(
  reviews: [
    ServiceReview(
      id: 31,
      rating: 5,
      comment: 'رائع جدا',
      isMine: true,
      userName: 'عمران ابراهيم',
    ),
  ],
  hasMore: false,
  summary: ServiceReviewSummary(
    averageRating: 4.4,
    totalReviews: 5,
    breakdown: {5: 3, 4: 1, 3: 1, 2: 0, 1: 0},
  ),
);

void main() {
  setUpAll(() {
    registerFallbackValue(
      const ServiceDetailParams(slug: 'amran', locale: 'en'),
    );
    registerFallbackValue(const ServiceImagesParams(slug: 'amran'));
    registerFallbackValue(
      const ServiceProductsParams(slug: 'amran', locale: 'en'),
    );
    registerFallbackValue(
      const ServiceProductCategoriesParams(slug: 'amran', locale: 'en'),
    );
    registerFallbackValue(
      const ServiceReviewsParams(slug: 'amran', locale: 'en'),
    );

    getIt.registerSingleton<GetServiceDetail>(_MockGetServiceDetail());
    getIt.registerSingleton<GetServiceImages>(_MockGetServiceImages());
    getIt.registerSingleton<GetServiceProducts>(_MockGetServiceProducts());
    getIt.registerSingleton<GetServiceProductCategories>(
      _MockGetServiceProductCategories(),
    );
    getIt.registerSingleton<GetServiceReviews>(_MockGetServiceReviews());
    getIt.registerSingleton<TokenRepository>(_MockTokenRepository());
    getIt.registerSingleton<GetCurrentLocation>(_MockGetCurrentLocation());
    getIt.registerSingleton<HasLocationAccess>(_MockHasLocationAccess());
    getIt.registerSingleton<FavoritesRepository>(_MockFavoritesRepository());
  });

  setUp(() {
    reset(getIt<GetServiceDetail>());
    reset(getIt<GetServiceImages>());
    reset(getIt<GetServiceProducts>());
    reset(getIt<GetServiceProductCategories>());
    reset(getIt<GetServiceReviews>());
    reset(getIt<TokenRepository>());
    reset(getIt<FavoritesRepository>());

    when(
      () => getIt<TokenRepository>().getToken(),
    ).thenAnswer((_) async => null);
    when(
      () => getIt<GetServiceDetail>().call(any()),
    ).thenAnswer((_) async => const Success(_detail));
    when(() => getIt<GetServiceImages>().call(any())).thenAnswer(
      (_) async => const Success(<String>['https://dalildimashq.com/a.jpg']),
    );
    when(
      () => getIt<GetServiceProducts>().call(any()),
    ).thenAnswer((_) async => const Success(_products));
    when(() => getIt<GetServiceProductCategories>().call(any())).thenAnswer(
      (_) async => const Success(<ServiceProductCategory>[
        ServiceProductCategory(
          slug: 'hot-drinks',
          name: 'مشروبات ساخنة',
          productsCount: 1,
        ),
      ]),
    );
    when(
      () => getIt<GetServiceReviews>().call(any()),
    ).thenAnswer((_) async => const Success(_reviewPage));
    when(() => getIt<FavoritesRepository>().add(any())).thenAnswer(
      (_) async => const Success(FavoriteMutation(isFavorited: true)),
    );
    when(() => getIt<FavoritesRepository>().remove(any())).thenAnswer(
      (_) async => const Success(FavoriteMutation(isFavorited: false)),
    );
  });

  Future<void> pumpProfile(WidgetTester tester, {String locale = 'en'}) async {
    final tokenCubit = TokenCubit(getIt<TokenRepository>());
    await tokenCubit.load();
    final locationCubit = LocationCubit(
      getIt<GetCurrentLocation>(),
      getIt<HasLocationAccess>(),
    );
    addTearDown(tokenCubit.close);
    addTearDown(locationCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: tokenCubit),
          BlocProvider.value(value: locationCubit),
          BlocProvider(
            create: (_) => FavoritesCubit(getIt<FavoritesRepository>()),
          ),
        ],
        child: MaterialApp(
          locale: Locale(locale),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const ServiceProfilePage(slug: 'amran'),
        ),
      ),
    );
    await tester.pump();
    await tester.pumpAndSettle();
  }

  testWidgets('shows the record, menu, opinions and hours', (tester) async {
    await pumpProfile(tester);

    expect(find.text('الاسد'), findsWidgets);
    expect(find.text('مطاعم · المزة'), findsOneWidget);
    expect(find.text('5 reviews'), findsWidgets);
    expect(find.text('قهوة عربي'), findsOneWidget);
    expect(find.text('رائع جدا'), findsOneWidget);
    expect(find.text('10:00 – 22:00'), findsOneWidget);
    expect(find.text('مكان صلاة111'), findsOneWidget);
    expect(find.text('0999111222'), findsOneWidget);
  });

  testWidgets('the Arabic screen shows the comments too', (tester) async {
    await pumpProfile(tester, locale: 'ar');

    expect(find.text('رائع جدا'), findsOneWidget);
    expect(find.text('عمران ابراهيم'), findsWidgets);
  });

  testWidgets('the heart toggles the service by its slug', (tester) async {
    await pumpProfile(tester);

    await tester.tap(find.byKey(const ValueKey('favorite-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(() => getIt<FavoritesRepository>().remove('amran')).called(1);
    expect(find.text('Removed from favorites'), findsOneWidget);
  });

  testWidgets('a failed record offers a retry that reads again', (
    tester,
  ) async {
    when(
      () => getIt<GetServiceDetail>().call(any()),
    ).thenAnswer((_) async => const FailureResult(ServerFailure()));

    await pumpProfile(tester);

    expect(
      find.text('Something went wrong while loading places'),
      findsOneWidget,
    );
    expect(find.text('الاسد'), findsNothing);

    await tester.tap(find.text('Retry'));
    await tester.pump();
    await tester.pumpAndSettle();

    verify(() => getIt<GetServiceDetail>().call(any())).called(2);
  });

  testWidgets('a stored token asks for the signed-in variant', (tester) async {
    when(
      () => getIt<TokenRepository>().getToken(),
    ).thenAnswer((_) async => 'abc');

    await pumpProfile(tester);

    final params =
        verify(
              () => getIt<GetServiceDetail>().call(captureAny()),
            ).captured.single
            as ServiceDetailParams;
    expect(params.slug, 'amran');
    expect(params.locale, 'en');
    expect(params.authenticated, isTrue);
  });
}
