import '../error/result.dart';

/// Signature for a domain use case: takes [Params] and returns a [Result].
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Convenience for use cases that take no parameters.
class NoParams {
  const NoParams();
}
