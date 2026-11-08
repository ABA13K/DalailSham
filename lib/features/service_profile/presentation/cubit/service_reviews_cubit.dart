import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_review.dart';
import '../../domain/usecases/get_service_reviews.dart';

enum ServiceReviewsStatus { initial, loading, ready, failure }

class ServiceReviewsState extends Equatable {
  const ServiceReviewsState({
    this.status = ServiceReviewsStatus.initial,
    this.summary = const ServiceReviewSummary(),
    this.reviews = const [],
    this.sort = ServiceReviewSort.latest,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final ServiceReviewsStatus status;
  final ServiceReviewSummary summary;
  final List<ServiceReview> reviews;
  final ServiceReviewSort sort;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  ServiceReviewsState copyWith({
    ServiceReviewsStatus? status,
    ServiceReviewSummary? summary,
    List<ServiceReview>? reviews,
    ServiceReviewSort? sort,
    bool? hasMore,
    bool? isLoadingMore,
  }) => ServiceReviewsState(
    status: status ?? this.status,
    summary: summary ?? this.summary,
    reviews: reviews ?? this.reviews,
    sort: sort ?? this.sort,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: null,
  );

  @override
  List<Object?> get props => [
    status,
    summary,
    reviews,
    sort,
    hasMore,
    isLoadingMore,
    failure,
  ];
}

/// The opinions under one service, ordered the way the reader asked and read
/// page by page.
class ServiceReviewsCubit extends Cubit<ServiceReviewsState> {
  ServiceReviewsCubit(this._getReviews) : super(const ServiceReviewsState());

  final GetServiceReviews _getReviews;

  String _slug = '';
  String _locale = 'en';
  bool _authenticated = false;
  int? _nextPage;
  int _requestId = 0;

  Future<void> load({
    required String slug,
    required String locale,
    bool authenticated = false,
  }) async {
    _slug = slug;
    _locale = locale;
    _authenticated = authenticated;
    _nextPage = null;
    final requestId = ++_requestId;
    emit(
      state.copyWith(
        status: ServiceReviewsStatus.loading,
        reviews: const [],
        hasMore: false,
      ),
    );
    await _fetch(requestId, page: 1, replace: true);
  }

  Future<void> changeSort(ServiceReviewSort sort) async {
    if (sort == state.sort && state.status == ServiceReviewsStatus.ready) {
      return;
    }
    final requestId = ++_requestId;
    _nextPage = null;
    emit(
      state.copyWith(
        status: ServiceReviewsStatus.loading,
        sort: sort,
        reviews: const [],
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

  Future<void> retry() => load(
    slug: _slug,
    locale: _locale,
    authenticated: _authenticated,
  );

  Future<void> _fetch(
    int requestId, {
    required int page,
    required bool replace,
  }) async {
    final result = await _getReviews(
      ServiceReviewsParams(
        slug: _slug,
        locale: _locale,
        page: page,
        sort: state.sort,
        authenticated: _authenticated,
      ),
    );
    if (isClosed || requestId != _requestId) return;
    result.fold(
      (failure) {
        if (replace) {
          emit(
            ServiceReviewsState(
              status: ServiceReviewsStatus.failure,
              sort: state.sort,
              failure: failure,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingMore: false));
        }
      },
      (reviewPage) {
        _nextPage = reviewPage.hasMore ? reviewPage.nextPage : null;
        emit(
          state.copyWith(
            status: ServiceReviewsStatus.ready,
            summary: reviewPage.summary,
            sort: reviewPage.sort,
            reviews: replace
                ? reviewPage.reviews
                : [...state.reviews, ...reviewPage.reviews],
            hasMore: _nextPage != null,
            isLoadingMore: false,
          ),
        );
      },
    );
  }
}