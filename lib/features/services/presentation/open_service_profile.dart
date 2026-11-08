import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../domain/entities/service_summary.dart';

/// Opens the profile of [service] when the listing gave it a slug. Listings
/// that only carry a name (no URL identifier) stay where they are.
void openServiceProfile(BuildContext context, ServiceSummary service) {
  final slug = service.slug;
  if (slug == null || slug.trim().isEmpty) return;
  final name = Uri.encodeComponent(service.name);
  context.push('/service/${Uri.encodeComponent(slug)}?name=$name');
}
