import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_category.dart';
import '../../domain/usecases/get_nearby_places.dart';

part 'places_event.dart';
part 'places_state.dart';

/// Loads nearby places and applies client-side filters.
class PlacesBloc extends Bloc<PlacesEvent, PlacesState> {
  PlacesBloc(this._getNearbyPlaces) : super(const PlacesState()) {
    on<PlacesRequested>(_onRequested);
    on<PlacesRefreshed>(_onRefreshed);
    on<PlaceCategoryFiltered>(_onCategoryFiltered);
    on<PlaceSearchQueryChanged>(_onQueryChanged);
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
    emit(state.copyWith(
      status: PlacesStatus.loading,
      lastRequest: params,
      clearFailure: true,
    ));
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
      (failure) => emit(state.copyWith(
        status: PlacesStatus.failure,
        failure: failure,
      )),
      (places) => emit(state.copyWith(
        status: PlacesStatus.success,
        allPlaces: places,
        visiblePlaces: _applyFilters(places, state.category, state.query),
        clearFailure: true,
      )),
    );
  }

  void _onCategoryFiltered(
    PlaceCategoryFiltered event,
    Emitter<PlacesState> emit,
  ) {
    emit(state.copyWith(
      category: event.category,
      clearCategory: event.category == null,
      visiblePlaces:
          _applyFilters(state.allPlaces, event.category, state.query),
    ));
  }

  void _onQueryChanged(
    PlaceSearchQueryChanged event,
    Emitter<PlacesState> emit,
  ) {
    final query = event.query.trim();
    emit(state.copyWith(
      query: query,
      visiblePlaces: _applyFilters(state.allPlaces, state.category, query),
    ));
  }

  List<Place> _applyFilters(
    List<Place> places,
    PlaceCategory? category,
    String query,
  ) {
    final normalizedQuery = query.toLowerCase();
    return places.where((place) {
      if (category != null && place.category != category) return false;
      if (normalizedQuery.isEmpty) return true;
      return place.name.toLowerCase().contains(normalizedQuery) ||
          (place.nameAr?.contains(query) ?? false) ||
          (place.address?.toLowerCase().contains(normalizedQuery) ?? false);
    }).toList();
  }
}
