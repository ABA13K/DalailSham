import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_product.dart';
import '../../domain/usecases/get_service_product_categories.dart';
import '../../domain/usecases/get_service_products.dart';

enum ServiceMenuStatus { initial, loading, ready, failure }

class ServiceMenuState extends Equatable {
  const ServiceMenuState({
    this.status = ServiceMenuStatus.initial,
    this.categories = const [],
    this.selectedCategory,
    this.products = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.total = 0,
    this.failure,
  });

  final ServiceMenuStatus status;
  final List<ServiceProductCategory> categories;

  /// Null reads the whole menu.
  final String? selectedCategory;
  final List<ServiceProduct> products;
  final bool hasMore;
  final bool isLoadingMore;
  final int total;
  final Failure? failure;

  ServiceMenuState copyWith({
    ServiceMenuStatus? status,
    List<ServiceProductCategory>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    List<ServiceProduct>? products,
    bool? hasMore,
    bool? isLoadingMore,
    int? total,
  }) => ServiceMenuState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    selectedCategory: clearCategory
        ? null
        : (selectedCategory ?? this.selectedCategory),
    products: products ?? this.products,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    total: total ?? this.total,
    failure: null,
  );

  @override
  List<Object?> get props => [
    status,
    categories,
    selectedCategory,
    products,
    hasMore,
    isLoadingMore,
    total,
    failure,
  ];
}

/// The menu of one service: its categories once, then the products of whichever
/// category the reader picked, page by page.
class ServiceMenuCubit extends Cubit<ServiceMenuState> {
  ServiceMenuCubit(this._getCategories, this._getProducts)
    : super(const ServiceMenuState());

  final GetServiceProductCategories _getCategories;
  final GetServiceProducts _getProducts;

  String _slug = '';
  String _locale = 'en';
  int? _nextPage;
  int _requestId = 0;

  Future<void> load({required String slug, required String locale}) async {
    _slug = slug;
    _locale = locale;
    _nextPage = null;
    final requestId = ++_requestId;
    emit(const ServiceMenuState(status: ServiceMenuStatus.loading));

    final categoriesFuture = _getCategories(
      ServiceProductCategoriesParams(slug: slug, locale: locale),
    );
    final productsFuture = _getProducts(
      ServiceProductsParams(slug: slug, locale: locale),
    );
    final categories = await categoriesFuture;
    final products = await productsFuture;
    if (isClosed || requestId != _requestId) return;

    final loadedCategories = categories.getOrElse((_) => const []);
    products.fold(
      (failure) => emit(
        ServiceMenuState(
          status: ServiceMenuStatus.failure,
          categories: loadedCategories,
          failure: failure,
        ),
      ),
      (page) {
        _nextPage = page.hasMore ? page.nextPage : null;
        emit(
          ServiceMenuState(
            status: ServiceMenuStatus.ready,
            categories: loadedCategories,
            products: page.products,
            hasMore: _nextPage != null,
            total: page.total,
          ),
        );
      },
    );
  }

  Future<void> selectCategory(String? categorySlug) async {
    if (categorySlug == state.selectedCategory) return;
    final requestId = ++_requestId;
    _nextPage = null;
    emit(
      state.copyWith(
        status: ServiceMenuStatus.loading,
        selectedCategory: categorySlug,
        clearCategory: categorySlug == null,
        products: const [],
        hasMore: false,
      ),
    );
    await _fetch(requestId, page: 1, replace: true);
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    if (next == null || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(++_requestId, page: next, replace: false);
  }

  Future<void> retry() => load(slug: _slug, locale: _locale);

  Future<void> _fetch(
    int requestId, {
    required int page,
    required bool replace,
  }) async {
    final result = await _getProducts(
      ServiceProductsParams(
        slug: _slug,
        locale: _locale,
        page: page,
        categorySlug: state.selectedCategory,
      ),
    );
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) {
        if (replace) {
          emit(
            ServiceMenuState(
              status: ServiceMenuStatus.failure,
              categories: state.categories,
              selectedCategory: state.selectedCategory,
              failure: failure,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingMore: false));
        }
      },
      (page) {
        _nextPage = page.hasMore ? page.nextPage : null;
        emit(
          state.copyWith(
            status: ServiceMenuStatus.ready,
            products: replace
                ? page.products
                : [...state.products, ...page.products],
            hasMore: _nextPage != null,
            isLoadingMore: false,
            total: page.total,
          ),
        );
      },
    );
  }
}