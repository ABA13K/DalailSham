import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/regions/domain/entities/region.dart';
import 'package:dali_alsham/features/regions/domain/repositories/region_repository.dart';

class RandomRegionsParams {
  const RandomRegionsParams({required this.locale, this.limit = 8});

  final String locale;
  final int limit;
}

class GetRandomRegions implements UseCase<List<Region>, RandomRegionsParams> {
  const GetRandomRegions(this._repository);

  final RegionRepository _repository;

  @override
  Future<Result<List<Region>>> call(RandomRegionsParams params) =>
      _repository.getRandomRegions(
        locale: params.locale,
        limit: params.limit,
      );
}
