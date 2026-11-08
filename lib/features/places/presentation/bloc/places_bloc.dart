import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/place.dart';
import '../../domain/usecases/get_nearby_places.dart';

part 'places_event.dart';
part 'places_state.dart';

/// Loads the places around the user, which the stories strip reads.
class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  PlacesBloc(this._getNearbyPlaces) : super(const PlacesState()) {
    on<PlacesRequested>(_onRequested);
    on<PlacesRefreshed>(_onRefreshed);
  }

  final GetNearbyPlaces _getNearbyPlaces;

  Future<void> _onRequested(
    PlacesRequested event,
    Emitter<PlacesState> emit,
  ) async {
    final params = NearbyPlacesParams(
      latitude: event.latitude,
      longitude: event.longitude,
      radiusMeters: event.radiusMeters,
    );
    emit(
      state.copyWith(
        status: PlacesStatus.loading,
        lastRequest: params,
        clearFailure: true,
      ),
    );
    await _load(params, emit);
  }

  Future<void> _onRefreshed(
    PlacesRefreshed event,
    Emitter<PlacesState> emit,
  ) async {
    final params = state.lastRequest;
    if (params == null) return;
    emit(state.copyWith(status: PlacesStatus.loading, clearFailure: true));
    await _load(params, emit);
  }

  Future<void> _load(
    NearbyPlacesParams params,
    Emitter<PlacesState> emit,
  ) async {
    final result = await _getNearbyPlaces(params);
    result.fold(
      (failure) =>
          emit(state.copyWith(status: PlacesStatus.failure, failure: failure)),
      (nearby) => emit(
        state.copyWith(
          status: PlacesStatus.success,
          allPlaces: nearby.places,
          clearFailure: true,
        ),
      ),
    );
  }
}
