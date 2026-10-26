import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/location/domain/entities/user_location.dart';
import 'package:dali_alsham/features/location/domain/repositories/location_repository.dart';

class GetCurrentLocation implements UseCase<UserLocation, NoParams> {
  const GetCurrentLocation(this._repository);

  final LocationRepository _repository;

  @override
  Future<Result<UserLocation>> call(NoParams params) =>
      _repository.getCurrentLocation();
}
