import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_search_query.dart';
import '../../domain/entities/service_sort.dart';
import '../../domain/entities/service_summary.dart';
import '../../domain/usecases/search_services.dart';

enum ServicesSearchStatus { initial, loading, ready, failure }

class ServicesSearchState extends Equatable {
  const ServicesSearchState({
    this.status = ServicesSearchStatus.initial,
    this.results = const [],
    this.text = '',
    this.categoryId,
    this.categoryName,
    this.regionId,
    this.regionName,
    this.sort,
    this.minRating,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final ServicesSearchStatus status;
  final List<ServiceSummary> results;

  /// The words in the search field.
  final String text;

  /// A chosen filter keeps its name so the chip can show what is filtered.
  final int? categoryId;
  final String? categoryName;
  final int? regionId;
  final String? regionName;
  final ServiceSort? sort;
  final double? minRating;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  bool get hasFilters =>
      categoryId != null ||
      regionId != null ||
      sort != null ||
      minRating != null;

  @override
  List<Object?> get props => [
    status,
    results,
    text,
    categoryId,
    categoryName,
    regionId,
    regionName,
    sort,
    minRating,
    hasMore,
    isLoadingMore,
    failure,
  ];
}

/// The search of published services: the typed words narrowed by category,
/// region, sort and minimum rating, loaded page by page.
///
/// The filters outlive one request, so choosing one re-runs the search with the
/// words still in the field.
class ServicesSearchCubit extends Cubit<ServicesSearchState> {
  ServicesSearchCubit(this._searchServices)
    : super(const ServicesSearchState());

  final SearchServices _searchServices;

  String _locale = 'en';
  bool _authenticated = false;
  double? _userLat;
  double? _userLng;
  String _text = '';
  int? _categoryId;
  String? _categoryName;
  int? _regionId;
  String? _regionName;
  ServiceSort? _sort;
  double? _minRating;
  int? _nextPage;
  bool _requestInFlight = false;

  /// Searches for [text] and forgets the previous results. An empty field is
  /// not a search, so it asks the backend for nothing.
  Future<void> search(
    String text, {
    required String locale,
    required bool authenticated,
    double? userLat,
    double? userLng,
  }) async {
    _text = text.trim();
    _locale = locale;
    _authenticated = authenticated;
    _userLat = userLat;
    _userLng = userLng;
    _nextPage = null;

    if (_text.isEmpty) {
      _emit(const ServicesSearchState());
      return;
    }
    _emit(const ServicesSearchState(status: ServicesSearchStatus.loading));
    await _fetch(page: 1, replace: true);
  }

  Future<void> chooseCategory(int id, String name) async {
    _categoryId = id;
    _categoryName = name;
    await _refilter();
  }

  Future<void> chooseRegion(int id, String name) async {
    _regionId = id;
    _regionName = name;
    await _refilter();
  }

  Future<void> chooseSort(ServiceSort sort) async {
    _sort = sort;
    await _refilter();
  }

  /// A null rating means "any", which is the filter cleared.
  Future<void> chooseMinRating(double? rating) async {
    _minRating = rating;
    await _refilter();
  }

  Future<void> clearFilters() async {
    _categoryId = null;
    _categoryName = null;
    _regionId = null;
    _regionName = null;
    _sort = null;
    _minRating = null;
    await _refilter();
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    if (next == null || _requestInFlight) return;
    _emit(
      _state(
        status: ServicesSearchStatus.ready,
        results: state.results,
        hasMore: state.hasMore,
        isLoadingMore: true,
      ),
    );
    await _fetch(page: next, replace: false);
  }

  Future<void> _refilter() async {
    if (_text.isEmpty) {
      _emit(_state(status: ServicesSearchStatus.initial, results: const []));
      return;
    }
    _nextPage = null;
    _emit(_state(status: ServicesSearchStatus.loading, results: const []));
    await _fetch(page: 1, replace: true);
  }

  Future<void> _fetch({required int page, required bool replace}) async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    final result = await _searchServices(
      ServiceSearchQuery(
        text: _text,
        locale: _locale,
        page: page,
        authenticated: _authenticated,
        userLat: _userLat,
        userLng: _userLng,
        categoryId: _categoryId,
        regionId: _regionId,
        sort: _sort,
        minRating: _minRating,
      ),
    );
    _requestInFlight = false;
    if (isClosed) return;

    result.fold(
      (failure) => _emit(
        replace
            ? _state(
                status: ServicesSearchStatus.failure,
                results: const [],
                failure: failure,
              )
            : // A page that will not arrive leaves what is on screen readable,
              // with the same button to try again.
              _state(
                status: ServicesSearchStatus.ready,
                results: state.results,
                hasMore: state.hasMore,
                failure: failure,
              ),
      ),
      (page) {
        _nextPage = page.hasMore ? page.nextPage : null;
        _emit(
          _state(
            status: ServicesSearchStatus.ready,
            results: replace
                ? page.services
                : [...state.results, ...page.services],
            hasMore: _nextPage != null,
          ),
        );
      },
    );
  }

  /// The filters live in the cubit, so every state carries the ones in force.
  ServicesSearchState _state({
    required ServicesSearchStatus status,
    required List<ServiceSummary> results,
    bool hasMore = false,
    bool isLoadingMore = false,
    Failure? failure,
  }) => ServicesSearchState(
    status: status,
    results: results,
    text: _text,
    categoryId: _categoryId,
    categoryName: _categoryName,
    regionId: _regionId,
    regionName: _regionName,
    sort: _sort,
    minRating: _minRating,
    hasMore: hasMore,
    isLoadingMore: isLoadingMore,
    failure: failure,
  );

  void _emit(ServicesSearchState next) {
    if (isClosed) return;
    emit(next);
  }
}
