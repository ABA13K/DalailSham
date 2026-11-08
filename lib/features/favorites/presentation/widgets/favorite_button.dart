import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../../services/domain/entities/service_summary.dart';
import '../cubit/favorites_cubit.dart';

/// Heart that adds or removes [service] from the signed-in user's favorites.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.service});

  final ServiceSummary service;

  @override
  Widget build(BuildContext context) {
    // Adding and removing both address the service by slug.
    if (service.slug == null) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final favorites = context.watch<FavoritesCubit>();
    final isFavorited = favorites.isFavorited(service);
    final isBusy = favorites.isBusy(service);

    return Semantics(
      button: true,
      selected: isFavorited,
      label: isFavorited ? l10n.removeFromFavorites : l10n.addToFavorites,
      child: IconButton(
        key: ValueKey('favorite-${service.id}'),
        onPressed: isBusy ? null : () => _toggle(context, favorites, l10n),
        icon: isBusy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                isFavorited
                    ? Icons.favorite_rounded
                    : Icons.favorite_outline_rounded,
                color: isFavorited
                    ? const Color(0xFFE53935)
                    : theme.colorScheme.outline,
              ),
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    FavoritesCubit favorites,
    AppLocalizations l10n,
  ) async {
    final outcome = await favorites.toggle(service);
    if (!context.mounted) return;

    final message = switch (outcome) {
      FavoriteOutcome.added => l10n.addedToFavorites,
      FavoriteOutcome.removed => l10n.removedFromFavorites,
      FavoriteOutcome.failure => l10n.favoritesError,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
