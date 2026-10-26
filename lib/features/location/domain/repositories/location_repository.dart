import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/location/domain/entities/user_location.dart';

abstract interface class LocationRepository {
  /// Returns the current position, or a failure when permission is denied
  /// or location services are disabled.
  Future<Result<UserLocation>> getCurrentLocation();
}
