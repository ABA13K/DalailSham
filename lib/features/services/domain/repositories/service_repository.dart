import 'package:dali_alsham/core/error/result.dart';

import '../entities/service_page.dart';
import '../entities/service_scope.dart';
import '../entities/service_search_query.dart';

abstract interface class ServiceRepository {
  /// One page of the services of [scope]; [scopeId] identifies the category or
  /// region and is ignored for [ServiceScope.favorites].
  ///
  /// When both [userLat] and [userLng] are given the backend sorts the list by
  /// distance and returns a distance label per service.
  ///
  /// [authenticated] selects the bearer-token variant of the listings that
  /// publish one; it is ignored by the scopes that have none.
  Future<Result<ServicePage>> getServices({
    required ServiceScope scope,
    required String locale,
    required int page,
    bool authenticated,
    int? scopeId,
    double? userLat,
    double? userLng,
  });

  /// One page of the search for [ServiceSearchQuery.text].
  Future<Result<ServicePage>> search(ServiceSearchQuery query);
}
