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

/// Services of one category, region or the signed-in user's favorites, loaded
/// page by page.
class ServicesCubit extends Cubit<ServicesState> {
  ServicesCubit(this._getServicePage) : super(const ServicesState());

  final GetServicePage _getServicePage;
  ServiceScope _scope = ServiceScope.category;
  int? _scopeId;
  String _locale = 'en';
  bool _authenticated = false;
  double? _userLat;
  double? _userLng;
  int? _nextPage;

  /// Pressing a tab sends a second listing request while the first is still
  /// away. Each request is numbered and only the newest one is allowed to
  /// speak, so the list ends up holding what the user last chose.
  int _requestId = 0;

  /// What the list on screen was fetched with. A refresh of the same choice
  /// keeps its rows, so only the section whose data moved repaints; a
  /// different pill or header is a different list and is worth blanking.
  ({ServiceScope scope, int? scopeId, String locale, bool authenticated})?
  _shown;

  Future<void> load({
    required ServiceScope scope,
    required String locale,
    int? scopeId,
    bool authenticated = false,
    double? userLat,
    double? userLng,
  }) async {
    _scope = scope;
    _scopeId = scopeId;
    _locale = locale;
    _authenticated = authenticated;
    _userLat = userLat;
    _userLng = userLng;
    _nextPage = null;
    final requestId = ++_requestId;
    final keepsList =
        _shown ==
            (
              scope: scope,
              scopeId: scopeId,
              locale: locale,
              authenticated: authenticated,
            ) &&
        state.services.isNotEmpty;
    if (!keepsList) {
      emit(const ServicesState(status: ServicesStatus.loading));
    }
    await _fetch(requestId, page: 1, replace: true, keepsList: keepsList);
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
    bool keepsList = false,
  }) async {
    final result = await _getServicePage(
      ServicePageParams(
        scope: _scope,
        scopeId: _scopeId,
        locale: _locale,
        page: page,
        authenticated: _authenticated,
        userLat: _userLat,
        userLng: _userLng,
      ),
    );
    if (isClosed || requestId != _requestId) return;
    if (replace) {
      _shown = (
        scope: _scope,
        scopeId: _scopeId,
        locale: _locale,
        authenticated: _authenticated,
      );
    }

    result.fold(
      (failure) {
        if (replace) {
          // Rows the reader can still see are not taken away because a refresh
          // did not answer; only a list with nothing on it says so.
          if (!keepsList) {
            emit(
              ServicesState(status: ServicesStatus.failure, failure: failure),
            );
          }
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
