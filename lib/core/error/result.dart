import 'failures.dart';

/// Minimal functional result type used across the domain layer.
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  R fold<R>(R Function(Failure failure) onFailure, R Function(T value) onSuccess) => switch (this) {
    Success<T>(:final value) => onSuccess(value),
    FailureResult<T>(:final failure) => onFailure(failure),
  };

  T getOrElse(T Function(Failure failure) orElse) =>
      fold(orElse, (value) => value);
}

class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  String toString() => 'Success($value)';
}

class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  String toString() => 'FailureResult($failure)';
}
