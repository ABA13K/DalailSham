import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/service_profile/domain/repositories/service_profile_repository.dart';

class ServiceImagesParams {
  const ServiceImagesParams({required this.slug});

  final String slug;
}

class GetServiceImages implements UseCase<List<String>, ServiceImagesParams> {
  const GetServiceImages(this._repository);

  final ServiceProfileRepository _repository;

  @override
  Future<Result<List<String>>> call(ServiceImagesParams params) =>
      _repository.getImages(slug: params.slug);
}