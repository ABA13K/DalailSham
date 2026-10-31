part of 'places_bloc.dart';

enum PlacesStatus { initial, loading, success, failure }

class PlacesState extends Equatable {
  const PlacesState({
    this.status = PlacesStatus.initial,
    this.allPlaces = const [],
    this.visiblePlaces = const [],
    this.category,
    this.query = '',
    this.failure,
    this.lastRequest,
    this.isDemoData = false,
  });

  final PlacesStatus status;

  /// Full result set from the last successful request.
  final List<Place> allPlaces;

  /// Result of applying [category] + [query] filters to [allPlaces].
  final List<Place> visiblePlaces;

  final PlaceCategory? category;
  final String query;
  final Failure? failure;

  /// Coordinates of the last request, used for refresh.
  final NearbyPlacesParams? lastRequest;

  /// True when [allPlaces] is offline sample data.
  final bool isDemoData;

  bool get hasFilters => category != null || query.isNotEmpty;

  PlacesState copyWith({
    PlacesStatus? status,
    List<Place>? allPlaces,
    List<Place>? visiblePlaces,
    PlaceCategory? category,
    String? query,
    Failure? failure,
    NearbyPlacesParams? lastRequest,
    bool? isDemoData,
    bool clearCategory = false,
    bool clearFailure = false,
  }) {
    return PlacesState(
      status: status ?? this.status,
      allPlaces: allPlaces ?? this.allPlaces,
      visiblePlaces: visiblePlaces ?? this.visiblePlaces,
      category: clearCategory ? null : (category ?? this.category),
      query: query ?? this.query,
      failure: clearFailure ? null : (failure ?? this.failure),
      lastRequest: lastRequest ?? this.lastRequest,
      isDemoData: isDemoData ?? this.isDemoData,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allPlaces,
    visiblePlaces,
    category,
    query,
    failure,
    lastRequest,
    isDemoData,
  ];
}
