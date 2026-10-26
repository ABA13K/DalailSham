import 'package:geolocator/geolocator.dart';

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../domain/entities/user_location.dart';
import '../domain/repositories/location_repository.dart';

class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository();

  @override
  Future<Result<UserLocation>> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const FailureResult(LocationServiceDisabledFailure());
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        return const FailureResult(LocationPermissionFailure());
      }
      if (permission == LocationPermission.deniedForever) {
        return const FailureResult(LocationPermissionFailure());
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return Success(
        UserLocation(latitude: position.latitude, longitude: position.longitude),
      );
    } on Exception catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
