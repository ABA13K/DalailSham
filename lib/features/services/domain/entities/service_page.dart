import 'service_summary.dart';

/// One page of a paginated services endpoint.
class ServicePage {
  const ServicePage({
    required this.services,
    required this.hasMore,
    this.nextPage,
  });

  final List<ServiceSummary> services;
  final bool hasMore;
  final int? nextPage;
}
