import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/service_profile/domain/entities/service_detail.dart';
import 'package:dali_alsham/features/service_profile/domain/repositories/service_profile_repository.dart';

class ServiceDetailParams {
  const ServiceDetailParams({
    required this.slug,
    required this.locale,
    this.authenticated = false,
    this.userLat,
    this.userLng,
  });

  final String slug;
  final String locale;
  final bool authenticated;
  final double? userLat;
  final double? userLng;
}

class GetServiceDetail implements UseCase<ServiceDetail, ServiceDetailParams> {
  const GetServiceDetail(this._repository);

  final ServiceProfileRepository _repository;

  @override
  Future<Result<ServiceDetail>> call(ServiceDetailParams params) =>
      _repository.getDetail(
        slug: params.slug,
        locale: params.locale,
        authenticated: params.authenticated,
        userLat: params.userLat,
        userLng: params.userLng,
      );
}