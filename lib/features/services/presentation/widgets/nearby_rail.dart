import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/service_page.dart';
import '../cubit/nearby_cubit.dart';
import 'services_rail.dart';

/// The services closest to where the user stands.
///
/// The endpoint answers with random services when the app has no location to
/// send, so the rail says what it actually shows rather than promising a
/// distance it never sorted by.
class NearbyRail extends StatelessWidget {
  const NearbyRail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NearbyCubit, NearbyState>(
      builder: (context, state) => ServicesRail(
        title: state.mode == ServiceListingMode.random
            ? AppLocalizations.of(context).nearbyRandomTitle
            : AppLocalizations.of(context).nearbyTitle,
        icon: Icons.near_me_rounded,
        status: state.status,
        services: state.services,
      ),
    );
  }
}
