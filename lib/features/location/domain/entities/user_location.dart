import 'package:equatable/equatable.dart';

/// Geographic position of the user.
class UserLocation extends Equatable {
  const UserLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  @override
  List<Object?> get props => [latitude, longitude];
}
