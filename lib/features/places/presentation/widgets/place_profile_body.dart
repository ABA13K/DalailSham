import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../../../core/utils/distance_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import '../../domain/entities/place_category.dart';
import 'company_profile.dart';
import 'place_menu.dart';

/// Everything below the cover on a business profile.
class PlaceProfileBody extends StatelessWidget {
  const PlaceProfileBody({
    super.key,
    required this.place,
    required this.profile,
  });

  final Place place;
  final CompanyProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasMenu =
        place.category == PlaceCategory.restaurant ||
        place.category == PlaceCategory.cafe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          icon: Icons.info_outline_rounded,
          title: l10n.sectionAbout,
        ),
        const SizedBox(height: 10),
        _AboutCard(profile: profile),
        const SizedBox(height: 20),
        _StatsCard(place: place, profile: profile),
        const SizedBox(height: 26),
        _SectionHeader(icon: Icons.place_outlined, title: l10n.sectionContact),
        const SizedBox(height: 10),
        _ContactCard(place: place),
        if (profile.amenities.isNotEmpty) ...[
          const SizedBox(height: 26),
          _SectionHeader(
            icon: Icons.check_circle_outline_rounded,
            title: l10n.sectionAmenities,
          ),
          const SizedBox(height: 10),
          _AmenitiesCard(amenities: profile.amenities),
        ],
        const SizedBox(height: 26),
        _SectionHeader(
          icon: Icons.reviews_outlined,
          title: l10n.sectionReviews,
        ),
        const SizedBox(height: 10),
        _ReviewsCard(place: place, distribution: profile.ratingDistribution),
        if (hasMenu) ...[
          const SizedBox(height: 26),
          PlaceMenu(category: place.category),
        ],
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

class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.profile});

  final CompanyProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final specialties = profile.specialties;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.about.forLocale(localeCode),
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
            ),
            if (specialties.length >= 2) ...[
              const SizedBox(height: 12),
              Text(
                l10n.profilePopularFor(
                  specialties[0].label.forLocale(localeCode),
                  specialties[1].label.forLocale(localeCode),
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
            if (specialties.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final specialty in specialties)
                    _TagChip(label: specialty.label.forLocale(localeCode)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.place, required this.profile});

  final Place place;
  final CompanyProfile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final reviews = NumberFormat.decimalPattern(
      localeCode,
    ).format(place.ratingCount);
    final divider = VerticalDivider(
      width: 1,
      indent: 14,
      endIndent: 14,
      color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
    );

    return Card(
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Stat(
                icon: Icons.reviews_outlined,
                value: reviews,
                label: l10n.labelReviews,
              ),
            ),
            divider,
            Expanded(
              child: _Stat(
                icon: Icons.payments_outlined,
                value: '\$' * profile.priceLevel,
                label: l10n.labelPrice,
              ),
            ),
            divider,
            Expanded(
              child: _Stat(
                icon: Icons.history_rounded,
                value: '${profile.sinceYear}',
                label: l10n.labelSince,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
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

class _AmenitiesCard extends StatelessWidget {
  const _AmenitiesCard({required this.amenities});

  final List<ProfileAmenity> amenities;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final amenity in amenities)
              Chip(
                avatar: Icon(
                  amenity.icon,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                label: Text(amenity.label.forLocale(localeCode)),
                labelStyle: theme.textTheme.labelMedium,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReviewsCard extends StatelessWidget {
  const _ReviewsCard({required this.place, required this.distribution});

  final Place place;
  final List<double> distribution;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final percentages = _percentages(distribution);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.ratingSummary(
                place.rating.toStringAsFixed(1),
                place.ratingCount,
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < distribution.length; i++) ...[
              if (i > 0) const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${5 - i}',
                    textDirection: TextDirection.ltr,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        height: 8,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ColoredBox(
                              color: theme.colorScheme.surfaceContainerHighest,
                            ),
                            FractionallySizedBox(
                              alignment: AlignmentDirectional.centerStart,
                              widthFactor: percentages[i] / 100,
                              child: ColoredBox(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 40),
                    child: Text(
                      '${percentages[i]}%',
                      maxLines: 1,
                      textAlign: TextAlign.end,
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Rounded percentages that always add up to 100.
  List<int> _percentages(List<double> values) {
    final raw = [for (final value in values) value * 100];
    final result = [for (final value in raw) value.floor()];
    var remaining = 100 - result.fold<int>(0, (sum, value) => sum + value);
    final order = List<int>.generate(raw.length, (index) => index)
      ..sort((a, b) => (raw[b] - result[b]).compareTo(raw[a] - result[a]));
    for (var i = 0; remaining > 0; i++, remaining--) {
      result[order[i % order.length]]++;
    }
    return result;
  }
}
