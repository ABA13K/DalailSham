import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_page.dart';
import '../../domain/entities/service_scope.dart';
import '../../domain/entities/service_summary.dart';
import '../../domain/usecases/get_service_page.dart';
import 'services_cubit.dart';

class TopRatedState extends Equatable {
  const TopRatedState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.failure,
  });

  final ServicesStatus status;
  final List<ServiceSummary> services;
  final Failure? failure;

  @override
  List<Object?> get props => [status, services, failure];
}

/// The best rated services of the whole directory, as one short list.
class TopRatedCubit extends Cubit<TopRatedState> {
  TopRatedCubit(this._getServicePage) : super(const TopRatedState());

  final GetServicePage _getServicePage;
  int _requestId = 0;

  /// What the list on screen was fetched with, so a refresh can tell whether
  /// the response describes the same set.
  ({String locale, bool authenticated, double? lat, double? lng})? _shown;

  Future<void> load({
    required String locale,
    required bool authenticated,
    double? userLat,
    double? userLng,
  }) async {
    final requestId = ++_requestId;
    final request = (
      locale: locale,
      authenticated: authenticated,
      lat: userLat,
      lng: userLng,
    );
    // A refresh keeps the rail on screen; a placeholder is only worth showing
    // while there is nothing to show yet.
    final keepsList = _shown == request && state.services.isNotEmpty;
    if (!keepsList) {
      emit(const TopRatedState(status: ServicesStatus.loading));
    }
    final result = await _getServicePage(
      ServicePageParams(
        scope: ServiceScope.topRated,
        locale: locale,
        authenticated: authenticated,
        userLat: userLat,
        userLng: userLng,
      ),
    );
    if (isClosed || requestId != _requestId) return;
    _shown = request;

    result.fold(
      (failure) {
        if (!keepsList) {
          emit(TopRatedState(status: ServicesStatus.failure, failure: failure));
        }
      },
      // An identical response leaves the state untouched.
      (ServicePage page) => emit(
        TopRatedState(status: ServicesStatus.ready, services: page.services),
      ),
    );
  }
}
