import 'package:dali_alsham/core/error/failures.dart';
import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/features/services/data/datasources/service_remote_datasource.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_scope.dart';
import 'package:dali_alsham/features/services/domain/repositories/service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  const ServiceRepositoryImpl(this._remoteDataSource);

  final ServiceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<ServicePage>> getServices({
    required ServiceScope scope,
    required int scopeId,
    required String locale,
    int page = 1,
    double? userLat,
    double? userLng,
  }) async {
    try {
      return Success(
        await _remoteDataSource.fetchServices(
          scope: scope,
          scopeId: scopeId,
          locale: locale,
          page: page,
          userLat: userLat,
          userLng: userLng,
        ),
      );
    } catch (error) {
      return FailureResult(failureFromException(error));
    }
  }
}
