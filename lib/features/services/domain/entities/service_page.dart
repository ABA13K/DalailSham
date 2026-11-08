import 'service_summary.dart';

/// How `/services/nearby` chose its rows: sorted around the sent location, or
/// picked without one when the app had no location to send.
enum ServiceListingMode {
  nearby('nearby'),
  random('random');

  const ServiceListingMode(this.wire);

  final String wire;

  static ServiceListingMode? fromWire(String? wire) {
    for (final mode in ServiceListingMode.values) {
      if (mode.wire == wire) return mode;
    }
    return null;
  }
}

/// One page of a paginated services endpoint.
class ServicePage {
  const ServicePage({
    required this.services,
    required this.hasMore,
    this.nextPage,
    this.mode,
  });

  final List<ServiceSummary> services;
  final bool hasMore;
  final int? nextPage;

  /// The `mode` the nearby listing answers with; null on the listings that
  /// never name one.
  final ServiceListingMode? mode;
}
