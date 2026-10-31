import 'package:dali_alsham/features/location/domain/repositories/location_repository.dart';

/// Whether location is currently usable, checked without prompting so it can
/// be called when the app returns to the foreground.
class HasLocationAccess {
  const HasLocationAccess(this._repository);

  final LocationRepository _repository;

  Future<bool> call() => _repository.hasLocationAccess();
}
