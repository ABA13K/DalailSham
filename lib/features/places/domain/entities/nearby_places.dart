import 'package:equatable/equatable.dart';

import 'place.dart';

/// Places around the user, flagged when they are offline sample data.
class NearbyPlaces extends Equatable {
  const NearbyPlaces({required this.places, this.isDemo = false});

  final List<Place> places;

  /// True when the live API was unavailable and [places] is demo content.
  final bool isDemo;

  @override
  List<Object?> get props => [places, isDemo];
}
