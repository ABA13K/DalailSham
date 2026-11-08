import 'package:dali_alsham/core/error/result.dart';
import 'package:dali_alsham/core/usecases/usecase.dart';
import 'package:dali_alsham/features/services/domain/entities/service_page.dart';
import 'package:dali_alsham/features/services/domain/entities/service_search_query.dart';
import 'package:dali_alsham/features/services/domain/repositories/service_repository.dart';

/// The services matching the typed words, narrowed by the chosen filters.
class SearchServices implements UseCase<ServicePage, ServiceSearchQuery> {
  const SearchServices(this._repository);

  final ServiceRepository _repository;

  @override
  Future<Result<ServicePage>> call(ServiceSearchQuery query) =>
      _repository.search(query);
}
