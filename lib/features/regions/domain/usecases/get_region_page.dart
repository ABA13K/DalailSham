import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/regions/domain/entities/region_page.dart';
import 'package:dali_alsham/features/regions/domain/repositories/region_repository.dart';

class RegionPageParams {
  const RegionPageParams({required this.locale, this.page = 1});

  final String locale;
  final int page;
}

class GetRegionPage implements UseCase<RegionPage, RegionPageParams> {
  const GetRegionPage(this._repository);

  final RegionRepository _repository;

  @override
  Future<Result<RegionPage>> call(RegionPageParams params) =>
      _repository.getRegions(locale: params.locale, page: params.page);
}
