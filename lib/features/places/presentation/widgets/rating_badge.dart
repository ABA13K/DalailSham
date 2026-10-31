import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';

/// Star rating and review count for a place.
class RatingBadge extends StatelessWidget {
  const RatingBadge({
    super.key,
    required this.place,
    this.onDark = false,
    this.showCount = true,
  });

  final Place place;

  /// Uses light text colors when placed over a dark background.
  final bool onDark;

  final bool showCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final value = place.rating.toStringAsFixed(1);

    return Semantics(
      label: l10n.ratingSummary(value, place.ratingCount),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, size: 16, color: Color(0xFFFFB300)),
            const SizedBox(width: 3),
            Flexible(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: onDark ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ),
            if (showCount) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  '(${place.ratingCount})',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: onDark
                        ? Colors.white.withValues(alpha: 0.75)
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
