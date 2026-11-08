import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/top_rated_cubit.dart';
import 'services_rail.dart';

/// The best rated services of the directory.
class TopRatedRail extends StatelessWidget {
  const TopRatedRail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TopRatedCubit, TopRatedState>(
      builder: (context, state) => ServicesRail(
        title: AppLocalizations.of(context).topRatedTitle,
        icon: Icons.emoji_events_rounded,
        status: state.status,
        services: state.services,
      ),
    );
  }
}
