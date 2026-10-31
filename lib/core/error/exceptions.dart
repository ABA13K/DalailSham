/// Low-level errors thrown by the data layer.
sealed class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException([super.message = 'Server error']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection']);
}

class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'Cache error']);
}

class ParseException extends AppException {
  const ParseException([super.message = 'Failed to parse response']);
}

class LocationPermissionException extends AppException {
  const LocationPermissionException([
    super.message = 'Location permission denied',
  ]);
}

class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException([
    super.message = 'Location services are disabled',
  ]);
}
