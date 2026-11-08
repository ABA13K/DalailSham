import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/service_page.dart';
import '../../domain/entities/service_scope.dart';
import '../../domain/entities/service_summary.dart';
import '../../domain/usecases/get_service_page.dart';
import 'services_cubit.dart';

class NearbyState extends Equatable {
  const NearbyState({
    this.status = ServicesStatus.initial,
    this.services = const [],
    this.mode,
    this.failure,
  });

  final ServicesStatus status;
  final List<ServiceSummary> services;

  /// What the listing says it picked with, which decides whether the rail may
  /// claim the rows are close to the user.
  final ServiceListingMode? mode;
  final Failure? failure;

  @override
  List<Object?> get props => [status, services, mode, failure];
}

/// The services closest to the location the user allowed, as one short list.
///
/// Without a location the endpoint still fills the rail, but with services
/// picked at random, so [NearbyState.mode] is what the rail titles itself by.
class NearbyCubit extends Cubit<NearbyState> {
  NearbyCubit(this._getServicePage) : super(const NearbyState());

  final GetServicePage _getServicePage;
  int _requestId = 0;

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
    final keepsList = _shown == request && state.services.isNotEmpty;
    if (!keepsList) {
      emit(const NearbyState(status: ServicesStatus.loading));
    }
    final result = await _getServicePage(
      ServicePageParams(
        scope: ServiceScope.nearby,
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
          emit(NearbyState(status: ServicesStatus.failure, failure: failure));
        }
      },
      (ServicePage page) => emit(
        NearbyState(
          status: ServicesStatus.ready,
          services: page.services,
          mode: page.mode,
        ),
      ),
    );
  }
}
