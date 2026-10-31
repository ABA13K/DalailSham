import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_scope.dart';
import '../../domain/entities/service_summary.dart';
import '../../domain/usecases/get_service_page.dart';

enum ServicesStatus { initial, loading, ready, failure }

class ServicesState extends Equatable {
  const ServicesState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.hasMore = false,
    this.isLoadingMore = false,
    this.failure,
  });

  final ServicesStatus status;
  final List<ServiceSummary> services;
  final bool hasMore;
  final bool isLoadingMore;
  final Failure? failure;

  ServicesState copyWith({
    ServicesStatus? status,
    List<ServiceSummary>? services,
    bool? hasMore,
    bool? isLoadingMore,
  }) => ServicesState(
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

/// Services of one category or region, loaded page by page.
class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit(this._getServicePage) : super(const ServicesState());

  final GetServicePage _getServicePage;
  ServiceScope _scope = ServiceScope.category;
  int _scopeId = 0;
  String _locale = 'en';
  double? _userLat;
  double? _userLng;
  int? _nextPage;
  bool _requestInFlight = false;

  Future<void> load({
    required ServiceScope scope,
    required int scopeId,
    required String locale,
    double? userLat,
    double? userLng,
  }) async {
    _scope = scope;
    _scopeId = scopeId;
    _locale = locale;
    _userLat = userLat;
    _userLng = userLng;
    _nextPage = null;
    emit(const ServicesState(status: ServicesStatus.loading));
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
    final result = await _getServicePage(
      ServicePageParams(
        scope: _scope,
        scopeId: _scopeId,
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
          emit(ServicesState(status: ServicesStatus.failure, failure: failure));
        } else {
          emit(state.copyWith(isLoadingMore: false));
        }
      },
      (servicePage) {
        _nextPage = servicePage.hasMore ? servicePage.nextPage : null;
        emit(
          ServicesState(
            status: ServicesStatus.ready,
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
