import 'package:dali_alsham/core/error/result.dart';

import '../entities/service_page.dart';
import '../entities/service_scope.dart';

abstract interface class ServiceRepository {
  /// One page of the services published inside [scopeId].
  ///
  /// When both [userLat] and [userLng] are given the backend sorts the list by
  /// distance and returns a distance label per service.
  Future<Result<ServicePage>> getServices({
    required ServiceScope scope,
    required int scopeId,
    required String locale,
    int page,
    double? userLat,
    double? userLng,
  });
}
