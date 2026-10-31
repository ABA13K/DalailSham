import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../domain/usecases/get_current_location.dart';
import '../domain/usecases/has_location_access.dart';

sealed class LocationState extends Equatable {
  const LocationState();

  @override
  List<Object?> get props => [];
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationReady extends LocationState {
  const LocationReady(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}

class LocationFailureState extends LocationState {
  const LocationFailureState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

/// Resolves the user's current position for the places feed.
class LocationCubit extends Cubit<LocationState> {
  LocationCubit(this._getCurrentLocation, this._hasLocationAccess)
    : super(const LocationInitial());

  final GetCurrentLocation _getCurrentLocation;
  final HasLocationAccess _hasLocationAccess;

  Future<void> locate() async {
    emit(const LocationLoading());
    final result = await _getCurrentLocation(const NoParams());
    result.fold(
      (failure) => emit(LocationFailureState(failure)),
      (location) => emit(LocationReady(location.latitude, location.longitude)),
    );
  }

  /// Re-resolves the position after the app returns to the foreground, but
  /// only when access was granted outside the app (e.g. system settings), so
  /// the user is not prompted again just for switching apps.
  Future<void> retryIfAccessGranted() async {
    if (state is! LocationFailureState) return;
    if (!await _hasLocationAccess()) return;
    if (isClosed) return;
    await locate();
  }
}
