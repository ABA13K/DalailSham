import 'package:flutter/material.dart';

import '../../../../core/utils/distance_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import 'category_info.dart';
import 'company_profile.dart';
import 'place_logo_mark.dart';

/// Cover banner of a business profile: logo, name and the listing's own facts.
class PlaceProfileHero extends StatelessWidget {
  const PlaceProfileHero({
    super.key,
    required this.place,
    required this.status,
    required this.hasStory,
    required this.onAvatarTap,
  });

  final Place place;
  final OpeningStatus? status;
  final bool hasStory;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final gradient = CategoryInfo.gradient(place.category);
    final name = place.displayNameFor(localeCode);
    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();
    final distance = place.distanceMeters;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          PositionedDirectional(
            top: -24,
            end: -28,
            child: Icon(
              CategoryInfo.icon(place.category),
              size: 220,
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          PositionedDirectional(
            bottom: -30,
            start: -24,
            child: Icon(
              CategoryInfo.icon(place.category),
              size: 130,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(
              20,
              kToolbarHeight + MediaQuery.paddingOf(context).top + 8,
              20,
              20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  key: const ValueKey('profile-avatar'),
                  behavior: HitTestBehavior.opaque,
                  onTap: onAvatarTap,
                  child: Semantics(
                    button: true,
                    label: l10n.profilePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: hasStory
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.9),
                                width: 2,
                              ),
                            )
                          : null,
                      child: PlaceLogoMark(
                        initial: initial,
                        gradient: gradient,
                        icon: CategoryInfo.icon(place.category),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _ProfileChip(
                      icon: CategoryInfo.icon(place.category),
                      label: CategoryInfo.label(l10n, place.category),
                    ),
                    if (status != null) _StatusChip(status: status!),
                    if (distance != null)
                      _ProfileChip(
                        icon: Icons.near_me_rounded,
                        label: formatDistance(l10n, distance),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileChip extends StatelessWidget {
  const _ProfileChip({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 5),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final OpeningStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (label, dotColor) = switch (status) {
      OpeningStatus.open => (l10n.statusOpenNow, const Color(0xFF69F0AE)),
      OpeningStatus.open24 => (l10n.statusOpen24, const Color(0xFF69F0AE)),
      OpeningStatus.closed => (l10n.statusClosed, const Color(0xFFFF8A80)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
