part of 'places_bloc.dart';

enum PlacesStatus { initial, loading, success, failure }

class PlacesState extends Equatable {
  const PlacesState({
    this.status = PlacesStatus.initial,
    this.allPlaces = const [],
    this.failure,
    this.lastRequest,
  });

  final PlacesStatus status;

  /// Result set from the last successful request, nearest first.
  final List<Place> allPlaces;

  final Failure? failure;

  /// Coordinates of the last request, used for refresh.
  final NearbyPlacesParams? lastRequest;

  PlacesState copyWith({
    PlacesStatus? status,
    List<Place>? allPlaces,
    Failure? failure,
    NearbyPlacesParams? lastRequest,
    bool clearFailure = false,
  }) {
    return PlacesState(
      status: status ?? this.status,
      allPlaces: allPlaces ?? this.allPlaces,
      failure: clearFailure ? null : (failure ?? this.failure),
      lastRequest: lastRequest ?? this.lastRequest,
    );
  }

  @override
  List<Object?> get props => [status, allPlaces, failure, lastRequest];
}
