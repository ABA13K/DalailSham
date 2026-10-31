import 'dart:async';

import 'package:geolocator/geolocator.dart';

import '../../../core/error/failures.dart';
import '../../../core/error/result.dart';
import '../domain/entities/user_location.dart';
import '../domain/repositories/location_repository.dart';

class GeolocatorLocationRepository implements LocationRepository {
  const GeolocatorLocationRepository();

  static const _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 20),
  );

  @override
  Future<Result<UserLocation>> getCurrentLocation() async {
    try {
      final blocked = await _blockedFailure(requestPermission: true);
      if (blocked != null) return FailureResult(blocked);

      final position = await _position();
      return Success(
        UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on Exception catch (error) {
      return FailureResult(failureFromException(error));
    }
  }

  @override
  Future<bool> hasLocationAccess() async {
    try {
      return await _blockedFailure(requestPermission: false) == null;
    } on Exception {
      return false;
    }
  }

  /// The failure blocking access, if any; never prompts unless asked to.
  Future<Failure?> _blockedFailure({required bool requestPermission}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return const LocationServiceDisabledFailure();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && requestPermission) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const LocationPermissionFailure();
    }
    return null;
  }

  /// Falls back to the last known fix when no new fix arrives in time, which
  /// is common indoors or right after permission is granted.
  Future<Position> _position() async {
    try {
      return await Geolocator.getCurrentPosition(locationSettings: _settings);
    } on TimeoutException {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown == null) rethrow;
      return lastKnown;
    }
  }
}
