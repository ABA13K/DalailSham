import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/repositories/service_repository.dart';

class ServicePageParams {
  const ServicePageParams({
    required this.scope,
    required this.scopeId,
    required this.locale,
    this.page = 1,
    this.userLat,
    this.userLng,
  });

  final ServiceScope scope;
  final int scopeId;
  final String locale;
  final int page;
  final double? userLat;
  final double? userLng;
}

class GetServicePage implements UseCase<ServicePage, ServicePageParams> {
  const GetServicePage(this._repository);

  final ServiceRepository _repository;

  @override
  Future<Result<ServicePage>> call(ServicePageParams params) =>
      _repository.getServices(
        scope: params.scope,
        scopeId: params.scopeId,
        locale: params.locale,
        page: params.page,
        userLat: params.userLat,
        userLng: params.userLng,
      );
}
