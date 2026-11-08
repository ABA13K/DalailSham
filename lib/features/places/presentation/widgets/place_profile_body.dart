import 'package:flutter/material.dart';

import '../../../../core/utils/distance_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';

/// Everything below the cover on a business profile: only what the listing
/// actually returned about the place.
class PlaceProfileBody extends StatelessWidget {
  const PlaceProfileBody({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(icon: Icons.place_outlined, title: l10n.sectionContact),
        const SizedBox(height: 10),
        _ContactCard(place: place),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final distance = place.distanceMeters;

    final rows = <Widget>[
      if (distance != null)
        _InfoRow(
          icon: Icons.near_me_rounded,
          label: l10n.labelDistance,
          value: formatDistance(l10n, distance),
        ),
      _InfoRow(
        icon: Icons.location_on_outlined,
        label: l10n.labelAddress,
        value: place.address ?? l10n.valueUnknown,
      ),
      _InfoRow(
        icon: Icons.access_time_rounded,
        label: l10n.labelOpeningHours,
        value: place.openingHours ?? l10n.valueUnknown,
        ltrText: true,
      ),
      if (place.phone != null)
        _InfoRow(
          icon: Icons.phone_outlined,
          label: l10n.labelPhone,
          value: place.phone!,
          ltrText: true,
        ),
      if (place.website != null)
        _InfoRow(
          icon: Icons.public_outlined,
          label: l10n.labelWebsite,
          value: place.website!,
        ),
    ];

    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        child: Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: rows[i],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.ltrText = false,
  });

  final IconData icon;
  final String label;
  final String value;

  /// Keeps numeric values (hours, phone) readable inside RTL layouts.
  final bool ltrText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                textDirection: ltrText ? TextDirection.ltr : null,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
