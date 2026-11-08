import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/story.dart';
import '../../domain/usecases/get_service_story_feed.dart';

enum ServiceStoryListStatus { initial, loading, ready, failure }

class ServiceStoryListState extends Equatable {
  const ServiceStoryListState({
    this.status = ServiceStoryListStatus.initial,
    this.stories = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final ServiceStoryListStatus status;
  final List<Story> stories;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  ServiceStoryListState copyWith({
    ServiceStoryListStatus? status,
    List<Story>? stories,
    bool? hasMore,
    bool? isLoadingMore,
  }) => ServiceStoryListState(
    status: status ?? this.status,
    stories: stories ?? this.stories,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    failure: failure,
  );

  @override
  List<Object?> get props => [
    status,
    stories,
    hasMore,
    isLoadingMore,
    failure,
  ];
}

/// Every story one service posted, page by page.
class ServiceStoryListCubit extends Cubit<ServiceStoryListState> {
  ServiceStoryListCubit(this._getServiceStoryFeed)
    : super(const ServiceStoryListState());

  final GetServiceStoryFeed _getServiceStoryFeed;
  int? _serviceId;
  String _locale = 'en';
  int? _nextPage;

  /// A page that arrives after the reader moved on to another service is
  /// dropped rather than written into the list on screen.
  int _requestId = 0;

  Future<void> load({required int serviceId, required String locale}) async {
    _serviceId = serviceId;
    _locale = locale;
    _nextPage = null;
    emit(const ServiceStoryListState(status: ServiceStoryListStatus.loading));
    await _fetch(++_requestId, page: 1, replace: true);
  }

  Future<void> loadMore() async {
    final next = _nextPage;
    if (next == null) return;
    emit(state.copyWith(isLoadingMore: true));
    await _fetch(++_requestId, page: next, replace: false);
  }

  Future<void> _fetch(
    int requestId, {
    required int page,
    required bool replace,
  }) async {
    final serviceId = _serviceId;
    if (serviceId == null) return;

    final result = await _getServiceStoryFeed(
      ServiceStoryFeedParams(serviceId: serviceId, locale: _locale, page: page),
    );
    if (isClosed || requestId != _requestId) return;

    result.fold(
      (failure) {
        if (replace) {
          emit(
            ServiceStoryListState(
              status: ServiceStoryListStatus.failure,
              failure: failure,
            ),
          );
        } else {
          emit(state.copyWith(isLoadingMore: false));
        }
      },
      (feed) {
        _nextPage = feed.hasMore ? feed.nextPage : null;
        emit(
          ServiceStoryListState(
            status: ServiceStoryListStatus.ready,
            stories: replace ? feed.stories : [...state.stories, ...feed.stories],
            hasMore: _nextPage != null,
          ),
        );
      },
    );
  }
}
