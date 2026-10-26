import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/utils/distance_formatter.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import '../widgets/category_info.dart';

/// Full details of a single place, with call / website / directions actions.
class PlaceDetailsPage extends StatelessWidget {
  const PlaceDetailsPage({super.key, required this.place});

  final Place place;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.detailsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Icon(
                  CategoryInfo.icon(place.category),
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.displayNameFor(localeCode),
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CategoryInfo.label(l10n, place.category),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                if (place.distanceMeters != null)
                  _DetailRow(
                    icon: Icons.near_me_rounded,
                    label: l10n.labelDistance,
                    value: formatDistance(l10n, place.distanceMeters!),
                  ),
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: l10n.labelAddress,
                  value: place.address ?? l10n.valueUnknown,
                ),
                _DetailRow(
                  icon: Icons.access_time_rounded,
                  label: l10n.labelOpeningHours,
                  value: place.openingHours ?? l10n.valueUnknown,
                ),
                if (place.phone != null)
                  _DetailRow(
                    icon: Icons.phone_outlined,
                    label: l10n.labelPhone,
                    value: place.phone!,
                  ),
                if (place.website != null)
                  _DetailRow(
                    icon: Icons.public_outlined,
                    label: l10n.labelWebsite,
                    value: place.website!,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => _launchExternal(
              context,
              mode: LaunchMode.externalApplication,
              uri: Uri.parse(
                'geo:${place.latitude},${place.longitude}'
                '?q=${Uri.encodeComponent(place.displayNameFor(localeCode))}',
              ),
              fallbackUri: Uri.parse(
                'https://www.google.com/maps/search/?api=1'
                '&query=${place.latitude},${place.longitude}',
              ),
            ),
            icon: const Icon(Icons.directions_rounded),
            label: Text(l10n.getDirections),
          ),
          const SizedBox(height: 12),
          if (place.phone != null)
            OutlinedButton.icon(
              onPressed: () => _launchExternal(
                context,
                mode: LaunchMode.externalApplication,
                uri: Uri(scheme: 'tel', path: place.phone),
              ),
              icon: const Icon(Icons.call_outlined),
              label: Text(l10n.call),
            ),
          if (place.website != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                var website = place.website!;
                if (!website.startsWith('http')) website = 'https://$website';
                _launchExternal(
                  context,
                  mode: LaunchMode.externalApplication,
                  uri: Uri.parse(website),
                );
              },
              icon: const Icon(Icons.public),
              label: Text(l10n.visitWebsite),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _launchExternal(
    BuildContext context, {
    required Uri uri,
    required LaunchMode mode,
    Uri? fallbackUri,
  }) async {
    final l10n = AppLocalizations.of(context);
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: mode);
    } catch (_) {
      launched = false;
    }
    if (!launched && fallbackUri != null) {
      try {
        launched = await launchUrl(fallbackUri, mode: mode);
      } catch (_) {
        launched = false;
      }
    }
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.unsupportedAction)),
      );
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(label, style: theme.textTheme.labelMedium),
      subtitle: Text(value, style: theme.textTheme.bodyMedium),
    );
  }
}
