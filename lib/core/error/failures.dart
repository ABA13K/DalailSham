import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Business-level errors surfaced to the presentation layer.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}

class ParsingFailure extends Failure {
  const ParsingFailure([super.message = 'Failed to parse data']);
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure([
    super.message = 'Location permission denied',
  ]);
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure([
    super.message = 'Location services are disabled',
  ]);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected error']);
}

/// Maps any [AppException] (or unknown error) to a [Failure].
Failure failureFromException(Object error) {
  if (error is AppException) {
    return switch (error) {
      ServerException() => ServerFailure(error.message),
      NetworkException() => NetworkFailure(error.message),
      TimeoutException() => TimeoutFailure(error.message),
      CacheException() => CacheFailure(error.message),
      ParseException() => ParsingFailure(error.message),
      LocationPermissionException() => LocationPermissionFailure(error.message),
      LocationServiceDisabledException() => LocationServiceDisabledFailure(
        error.message,
      ),
    };
  }
  return UnexpectedFailure(error.toString());
}
