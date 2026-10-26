part of 'places_bloc.dart';

sealed class PlacesEvent extends Equatable {
  const PlacesEvent();

  @override
  List<Object?> get props => [];
}

/// Loads places around the given coordinates.
class PlacesRequested extends PlacesEvent {
  const PlacesRequested({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 2000,
  });

  final double latitude;
  final double longitude;
  final int radiusMeters;

  @override
  List<Object?> get props => [latitude, longitude, radiusMeters];
}

/// Re-fetches using the coordinates of the last successful request.
class PlacesRefreshed extends PlacesEvent {
  const PlacesRefreshed();
}

/// Applies a client-side category filter (`null` = all).
class PlaceCategoryFiltered extends PlacesEvent {
  const PlaceCategoryFiltered(this.category);

  final PlaceCategory? category;

  @override
  List<Object?> get props => [category];
}

/// Applies a client-side text query.
class PlaceSearchQueryChanged extends PlacesEvent {
  const PlaceSearchQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}
