import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/settings/presentation/token_cubit.dart';
import '../../../../core/widgets/centered_content.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../di/injection.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../../location/presentation/location_cubit.dart';
import '../../../services/domain/entities/service_summary.dart';
import '../../domain/entities/service_detail.dart';
import '../../domain/usecases/get_service_detail.dart';
import '../../domain/usecases/get_service_images.dart';
import '../../domain/usecases/get_service_product_categories.dart';
import '../../domain/usecases/get_service_products.dart';
import '../../domain/usecases/get_service_reviews.dart';
import '../cubit/service_menu_cubit.dart';
import '../cubit/service_profile_cubit.dart';
import '../cubit/service_reviews_cubit.dart';
import '../widgets/service_gallery_strip.dart';
import '../widgets/service_menu_section.dart';
import '../widgets/service_profile_shared.dart';
import '../widgets/service_reviews_section.dart';

/// Everything one service publishes: its record, its pictures, its menu and
/// what readers said, read from the public or signed-in endpoints depending on
/// whether a token is stored.
class ServiceProfilePage extends StatelessWidget {
  const ServiceProfilePage({super.key, required this.slug, this.initialName});

  /// URL identifier of the service (`amran` in `/services/amran`).
  final String slug;

  /// Name the listing already knew, shown until the record arrives.
  final String? initialName;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final location = context.watch<LocationCubit>().state;
    final userLat = location is LocationReady ? location.latitude : null;
    final userLng = location is LocationReady ? location.longitude : null;
    final hasToken = context.select<TokenCubit, bool>(
      (cubit) => cubit.state != null,
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              ServiceProfileCubit(
                getIt<GetServiceDetail>(),
                getIt<GetServiceImages>(),
              )..load(
                slug: slug,
                locale: locale,
                authenticated: hasToken,
                userLat: userLat,
                userLng: userLng,
              ),
        ),
        BlocProvider(
          create: (_) => ServiceMenuCubit(
            getIt<GetServiceProductCategories>(),
            getIt<GetServiceProducts>(),
          )..load(slug: slug, locale: locale),
        ),
        BlocProvider(
          create: (_) =>
              ServiceReviewsCubit(getIt<GetServiceReviews>())
                ..load(slug: slug, locale: locale, authenticated: hasToken),
        ),
      ],
      child: _ServiceProfileView(initialName: initialName),
    );
  }
}

class _ServiceProfileView extends StatelessWidget {
  const _ServiceProfileView({this.initialName});

  final String? initialName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<ServiceProfileCubit, ServiceProfileState>(
      builder: (context, state) {
        final detail = state.detail;
        final title = detail?.name ?? initialName ?? l10n.profileTitle;

        if (state.status == ServiceProfileStatus.failure) {
          return Scaffold(
            appBar: AppBar(title: Text(title, maxLines: 1)),
            body: CenteredContent(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.placesError, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<ServiceProfileCubit>().refresh(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (detail == null) {
          return Scaffold(
            appBar: AppBar(title: Text(title, maxLines: 1)),
            body: const _ProfileShimmer(),
          );
        }

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 240,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                title: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      ServicePhoto(
                        url: detail.mainImage,
                        icon: Icons.storefront_rounded,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black54],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: CenteredContent(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                    child: _DetailBody(detail: detail),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.detail});

  final ServiceDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HeadingCard(detail: detail),
        const SizedBox(height: 16),
        _QuickActions(detail: detail),
        if (detail.description != null) ...[
          const SizedBox(height: 24),
          ServiceSectionHeader(
            icon: Icons.info_outline_rounded,
            title: l10n.sectionAbout,
          ),
          const SizedBox(height: 8),
          Text(
            detail.description!,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
        const SizedBox(height: 24),
        ServiceSectionHeader(
          icon: Icons.photo_library_outlined,
          title: l10n.sectionPhotos,
          trailing: detail.imagesCount > 0
              ? Text(
                  l10n.photosCount(detail.imagesCount),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        const ServiceGalleryStrip(),
        const SizedBox(height: 24),
        const ServiceMenuSection(),
        const SizedBox(height: 24),
        const ServiceReviewsSection(),
        if (detail.contacts.isNotEmpty) ...[
          const SizedBox(height: 24),
          ServiceSectionHeader(
            icon: Icons.contact_phone_outlined,
            title: l10n.sectionContact,
          ),
          const SizedBox(height: 10),
          _ContactsCard(contacts: detail.contacts),
        ],
        if (detail.workingHours.isNotEmpty) ...[
          const SizedBox(height: 24),
          ServiceSectionHeader(
            icon: Icons.access_time_rounded,
            title: l10n.sectionHours,
          ),
          const SizedBox(height: 10),
          _HoursCard(days: detail.workingHours),
        ],
        if (detail.amenities.isNotEmpty) ...[
          const SizedBox(height: 24),
          ServiceSectionHeader(
            icon: Icons.auto_awesome_outlined,
            title: l10n.sectionAmenities,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amenity in detail.amenities)
                Chip(
                  avatar: Icon(
                    Icons.check_circle_rounded,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  label: Text(amenity),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _HeadingCard extends StatelessWidget {
  const _HeadingCard({required this.detail});

  final ServiceDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final grouping = [
      detail.categoryName,
      detail.regionName,
    ].whereType<String>().where((value) => value.trim().isNotEmpty).join(' · ');
    final distance = detail.distanceText;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (grouping.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          grouping,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                FavoriteButton(service: _favoriteTarget),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ServiceStars(rating: detail.rating, size: 18),
                Text(
                  detail.rating.toStringAsFixed(1),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  l10n.reviewsCount(detail.reviewsCount),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (distance != null)
                  _Badge(
                    icon: Icons.near_me_rounded,
                    text: distance,
                    background: scheme.secondaryContainer,
                    foreground: scheme.onSecondaryContainer,
                  ),
                if (detail.isOpenNow != null)
                  _Badge(
                    icon: detail.isOpenNow!
                        ? Icons.schedule_rounded
                        : Icons.lock_clock_rounded,
                    text: detail.isOpenNow!
                        ? l10n.statusOpenNow
                        : l10n.statusClosed,
                    background: detail.isOpenNow!
                        ? const Color(0xFF1B8A5A).withValues(alpha: 0.12)
                        : scheme.errorContainer,
                    foreground: detail.isOpenNow!
                        ? const Color(0xFF1B8A5A)
                        : scheme.onErrorContainer,
                  ),
              ],
            ),
            if (detail.address != null) ...[
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: scheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      detail.address!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (detail.visitsCount > 0) ...[
              const SizedBox(height: 6),
              Text(
                l10n.visitsCount(detail.visitsCount),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The heart toggles by slug; the record carries everything else.
  ServiceSummary get _favoriteTarget => ServiceSummary(
    id: detail.id,
    name: detail.name,
    slug: detail.slug,
    categoryName: detail.categoryName,
    regionName: detail.regionName,
    address: detail.address,
    rating: detail.rating,
    reviewsCount: detail.reviewsCount,
    isFavorited: detail.isFavorited,
    distanceText: detail.distanceText,
    imageUrl: detail.mainImage,
  );
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.detail});

  final ServiceDetail detail;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final phone = detail.phone;
    final website = detail.website;
    final mapsUri = _mapsUri();

    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.call_rounded,
            label: l10n.call,
            onTap: phone == null
                ? null
                : () => _launch(context, Uri(scheme: 'tel', path: phone)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.directions_rounded,
            label: l10n.directions,
            onTap: mapsUri == null
                ? null
                : () => _launch(context, mapsUri, fallback: _googleMapsUri()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.public_rounded,
            label: l10n.visitWebsite,
            onTap: website == null
                ? null
                : () => _launch(context, _httpUri(website)),
          ),
        ),
      ],
    );
  }

  Uri? _googleMapsUri() {
    final lat = detail.lat;
    final lng = detail.lng;
    if (lat == null || lng == null) return null;
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
  }

  Uri? _mapsUri() {
    final maps = detail.mapsUrl;
    if (maps != null && maps.trim().isNotEmpty) {
      final parsed = Uri.tryParse(maps.trim());
      if (parsed != null) return parsed;
    }
    final lat = detail.lat;
    final lng = detail.lng;
    if (lat == null || lng == null) return null;
    return Uri.parse('geo:$lat,$lng?q=${Uri.encodeComponent(detail.name)}');
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabled = onTap != null;
    final foreground = enabled
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreground),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactsCard extends StatelessWidget {
  const _ContactsCard({required this.contacts});

  final List<ServiceContactGroup> contacts;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rows = <Widget>[];
    for (final group in contacts) {
      for (final value in group.values) {
        if (rows.isNotEmpty) {
          rows.add(
            Divider(
              height: 1,
              indent: 56,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          );
        }
        rows.add(
          ListTile(
            leading: Icon(
              _iconFor(group.type),
              color: theme.colorScheme.primary,
            ),
            title: Text(
              value.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(group.label),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _openContact(context, group.type, value.value),
          ),
        );
      }
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(children: rows),
    );
  }

  static IconData _iconFor(String type) => switch (type) {
    'phone' => Icons.phone_outlined,
    'email' => Icons.email_outlined,
    'website' => Icons.public_rounded,
    'instagram' => Icons.photo_camera_outlined,
    'facebook' => Icons.facebook_rounded,
    'telegram' => Icons.send_outlined,
    'whatsapp' => Icons.chat_bubble_outline_rounded,
    _ => Icons.link_rounded,
  };
}

class _HoursCard extends StatelessWidget {
  const _HoursCard({required this.days});

  final List<ServiceWorkingDay> days;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Column(
          children: [
            for (var index = 0; index < days.length; index++) ...[
              if (index > 0)
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        days[index].day,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      _range(l10n, days[index]),
                      textDirection: TextDirection.ltr,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: days[index].isClosed
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _range(AppLocalizations l10n, ServiceWorkingDay day) {
    if (day.isClosed) return l10n.statusClosed;
    final open = _shortTime(day.openTime);
    final close = _shortTime(day.closeTime);
    if (open == null || close == null) return l10n.valueUnknown;
    return '$open – $close';
  }

  static String? _shortTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0]}:${parts[1]}';
  }
}

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ShimmerBox(height: 200, borderRadius: 20),
        SizedBox(height: 16),
        ShimmerBox(height: 24, width: 180, borderRadius: 8),
        SizedBox(height: 10),
        ShimmerBox(height: 16, borderRadius: 6),
        SizedBox(height: 10),
        ShimmerBox(height: 16, width: 240, borderRadius: 6),
        SizedBox(height: 20),
        ShimmerBox(height: 64, borderRadius: 14),
        SizedBox(height: 20),
        ShimmerBox(height: 120, borderRadius: 16),
      ],
    );
  }
}

Future<void> _launch(BuildContext context, Uri uri, {Uri? fallback}) async {
  var launched = false;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    launched = false;
  }
  if (!launched && fallback != null) {
    try {
      launched = await launchUrl(
        fallback,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      launched = false;
    }
  }
  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).unsupportedAction)),
    );
  }
}

void _openContact(BuildContext context, String type, String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return;

  final uri = switch (type) {
    'phone' => Uri(scheme: 'tel', path: trimmed),
    'email' => Uri(scheme: 'mailto', path: trimmed),
    'whatsapp' => Uri.parse(
      'https://wa.me/${trimmed.replaceAll(RegExp(r'[^0-9]'), '')}',
    ),
    'telegram' => _telegramUri(trimmed),
    _ => _httpUri(trimmed),
  };
  _launch(context, uri, fallback: _httpUri(trimmed));
}

Uri _telegramUri(String value) {
  if (_isHttp(value)) return Uri.parse(value);
  if (value.startsWith('@')) {
    return Uri.parse('https://t.me/${value.substring(1)}');
  }
  final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
  return Uri.parse('https://t.me/+$digits');
}

Uri _httpUri(String value) {
  if (_isHttp(value)) return Uri.parse(value);
  return Uri.parse('https://$value');
}

bool _isHttp(String value) =>
    value.startsWith('http://') || value.startsWith('https://');
