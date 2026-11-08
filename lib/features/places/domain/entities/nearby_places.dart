import 'package:equatable/equatable.dart';

import 'place.dart';

/// Places around the user, as the live listing returned them.
class NearbyPlaces extends Equatable {
  const NearbyPlaces({required this.places});

  final List<Place> places;

  @override
  List<Object?> get props => [places];
}
