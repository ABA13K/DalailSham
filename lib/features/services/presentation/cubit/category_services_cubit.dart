import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/category_service.dart';
import '../../domain/usecases/get_category_service_page.dart';

enum CategoryServicesStatus { initial, loading, ready, failure }

class CategoryServicesState extends Equatable {
  const CategoryServicesState({
    this.status = CategoryServicesStatus.initial,
    this.services = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final CategoryServicesStatus status;
  final List<CategoryService> services;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  CategoryServicesState copyWith({
    CategoryServicesStatus? status,
    List<CategoryService>? services,
    bool? hasMore,
    bool? isLoadingMore,
  }) => CategoryServicesState(
    status: status ?? this.status,
    services: services ?? this.services,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    status,
    services,
    hasMore,
    isLoadingMore,
    failure,
  ];
}

/// Services of one category, loaded page by page.
class CategoryServicesCubit extends Cubit<CategoryServicesState> {
  CategoryServicesCubit(this._getServicePage)
    : super(const CategoryServicesState());

  final GetCategoryServicePage _getServicePage;
  int? _categoryId;
  String _locale = 'en';
  double? _userLat;
  double? _userLng;
  int? _nextPage;
  bool _requestInFlight = false;

  Future<void> load({
    required int categoryId,
    required String locale,
    double? userLat,
    double? userLng,
  }) async {
    _categoryId = categoryId;
    _locale = locale;
    _userLat = userLat;
    _userLng = userLng;
    _nextPage = null;
    emit(const CategoryServicesState(status: CategoryServicesStatus.loading));
    await _fetch(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    if (next == null || _requestInFlight) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: next, replace: false);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    final categoryId = _categoryId;
    if (categoryId == null || _requestInFlight) return;
    _requestInFlight = true;
    final result = await _getServicePage(
      CategoryServicePageParams(
        categoryId: categoryId,
        locale: _locale,
        page: page,
        userLat: _userLat,
        userLng: _userLng,
      ),
    );
    _requestInFlight = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (replace) {
          emit(
            CategoryServicesState(
              status: CategoryServicesStatus.failure,
              failure: failure,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingMore: false));
        }
      },
      (servicePage) {
        _nextPage = servicePage.hasMore ? servicePage.nextPage : null;
        emit(
          CategoryServicesState(
            status: CategoryServicesStatus.ready,
            services: replace
                ? servicePage.services
                : [...state.services, ...servicePage.services],
            hasMore: _nextPage != null,
          ),
        );
      },
    );
  }
}
