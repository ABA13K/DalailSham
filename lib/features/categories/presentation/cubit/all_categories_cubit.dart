import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/explore_category.dart';
import '../../domain/usecases/get_category_page.dart';

enum AllCategoriesStatus { initial, loading, ready, failure }

class AllCategoriesState extends Equatable {
  const AllCategoriesState({
    this.status = AllCategoriesStatus.initial,
    this.categories = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final AllCategoriesStatus status;
  final List<ExploreCategory> categories;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  AllCategoriesState copyWith({
    AllCategoriesStatus? status,
    List<ExploreCategory>? categories,
    bool? hasMore,
    bool? isLoadingMore,
  }) => AllCategoriesState(
    status: status ?? this.status,
    categories: categories ?? this.categories,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    status,
    categories,
    hasMore,
    isLoadingMore,
    failure,
  ];
}

/// Paginated list of every category, used by the "see all" screen.
class AllCategoriesCubit extends Cubit<AllCategoriesState> {
  AllCategoriesCubit(this._getCategoryPage) : super(const AllCategoriesState());

  final GetCategoryPage _getCategoryPage;
  String _locale = 'en';
  int? _nextPage;
  bool _requestInFlight = false;

  Future<void> load(String locale) async {
    _locale = locale;
    _nextPage = null;
    emit(const AllCategoriesState(status: AllCategoriesStatus.loading));
    await _fetch(page: 1, replace: true);
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    if (next == null || _requestInFlight) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(page: next, replace: false);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    final result = await _getCategoryPage(
      CategoryPageParams(locale: _locale, page: page),
    );
    _requestInFlight = false;
    if (isClosed) return;

    result.fold(
      (failure) {
        if (replace) {
          emit(
            AllCategoriesState(
              status: AllCategoriesStatus.failure,
              failure: failure,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingMore: false));
        }
      },
      (categoryPage) {
        _nextPage = categoryPage.hasMore ? categoryPage.nextPage : null;
        emit(
          AllCategoriesState(
            status: AllCategoriesStatus.ready,
            categories: replace
                ? categoryPage.categories
                : [...state.categories, ...categoryPage.categories],
            hasMore: _nextPage != null,
          ),
        );
      },
    );
  }
}
