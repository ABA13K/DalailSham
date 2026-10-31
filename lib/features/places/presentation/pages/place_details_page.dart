import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/centered_content.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import '../widgets/category_info.dart';
import '../widgets/company_profile.dart';
import '../widgets/place_logo_mark.dart';
import '../widgets/place_photo_view.dart';
import '../widgets/place_profile_body.dart';
import '../widgets/place_profile_hero.dart';
import 'stories_page.dart';

enum _AvatarAction { photo, story }

/// Professional business profile for a single place, with quick contact
/// actions and a collapsing cover.
class PlaceDetailsPage extends StatelessWidget {
  const PlaceDetailsPage({
    super.key,
    required this.place,
    this.hasStory = true,
  });

  final Place place;

  /// Every place currently ships with a generated story.
  final bool hasStory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final profile = CompanyProfile(place);
    final gradient = CategoryInfo.gradient(place.category);
    final scale = MediaQuery.textScalerOf(context).scale(1);
    final expandedHeight = (360 + (scale - 1) * 180).clamp(360.0, 720.0);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            backgroundColor: gradient.colors.last,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            titleTextStyle: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            title: Text(
              l10n.profileTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: PlaceProfileHero(
                place: place,
                profile: profile,
                status: profile.openingStatus,
                hasStory: hasStory,
                onAvatarTap: () => _showAvatarOptions(context),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CenteredContent(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _QuickActions(
                      place: place,
                      onCall: () => _call(context),
                      onDirections: () => _openDirections(context),
                      onWebsite: () => _openWebsite(context),
                      onChat: () => context.push('/chat', extra: place),
                    ),
                    const SizedBox(height: 12),
                    if (hasStory) ...[
                      FilledButton.tonalIcon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        onPressed: () => _openStory(context),
                        icon: const Icon(Icons.play_circle_fill_rounded),
                        label: Text(l10n.viewStory),
                      ),
                    ],
                    const SizedBox(height: 22),
                    PlaceProfileBody(place: place, profile: profile),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openStory(BuildContext context) {
    context.push('/stories', extra: StoriesArgs(places: [place]));
  }

  Future<void> _showAvatarOptions(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final name = place.displayNameFor(localeCode);
    final gradient = CategoryInfo.gradient(place.category);

    final action = await showModalBottomSheet<_AvatarAction>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: PlaceLogoMark(
                size: 44,
                initial: _initialOf(name),
                gradient: gradient,
                icon: CategoryInfo.icon(place.category),
              ),
              title: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(CategoryInfo.label(l10n, place.category)),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.image_outlined),
              title: Text(l10n.viewPhoto),
              onTap: () => Navigator.of(sheetContext).pop(_AvatarAction.photo),
            ),
            if (hasStory)
              ListTile(
                leading: const Icon(Icons.play_circle_outline_rounded),
                title: Text(l10n.viewStory),
                onTap: () =>
                    Navigator.of(sheetContext).pop(_AvatarAction.story),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case _AvatarAction.photo:
        _showPhoto(context);
      case _AvatarAction.story:
        _openStory(context);
      case null:
        break;
    }
  }

  Future<void> _showPhoto(BuildContext context) {
    final name = place.displayNameFor(
      Localizations.localeOf(context).languageCode,
    );

    return showDialog<void>(
      context: context,
      barrierColor: Colors.black,
      builder: (dialogContext) => Dialog.fullscreen(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Positioned.fill(
              child: PlacePhotoView(place: place, initial: _initialOf(name)),
            ),
            PositionedDirectional(
              top: 0,
              end: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: IconButton(
                    key: const ValueKey('profile-photo-close'),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    tooltip: MaterialLocalizations.of(
                      dialogContext,
                    ).closeButtonTooltip,
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.32),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initialOf(String name) {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }

  Future<void> _call(BuildContext context) async {
    final phone = place.phone;
    if (phone == null) return;
    await _launchExternal(
      context,
      mode: LaunchMode.externalApplication,
      uri: Uri(scheme: 'tel', path: phone),
    );
  }

  Future<void> _openWebsite(BuildContext context) async {
    var website = place.website;
    if (website == null) return;
    if (!website.startsWith('http')) website = 'https://$website';
    await _launchExternal(
      context,
      mode: LaunchMode.externalApplication,
      uri: Uri.parse(website),
    );
  }

  Future<void> _openDirections(BuildContext context) async {
    final name = place.displayNameFor(
      Localizations.localeOf(context).languageCode,
    );
    await _launchExternal(
      context,
      mode: LaunchMode.externalApplication,
      uri: Uri.parse(
        'geo:${place.latitude},${place.longitude}'
        '?q=${Uri.encodeComponent(name)}',
      ),
      fallbackUri: Uri.parse(
        'https://www.google.com/maps/search/?api=1'
        '&query=${place.latitude},${place.longitude}',
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.unsupportedAction)));
    }
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.place,
    required this.onCall,
    required this.onDirections,
    required this.onWebsite,
    required this.onChat,
  });

  final Place place;
  final VoidCallback onCall;
  final VoidCallback onDirections;
  final VoidCallback onWebsite;
  final VoidCallback onChat;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Row(
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.call_rounded,
            label: l10n.call,
            onTap: place.phone == null ? null : onCall,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.directions_rounded,
            label: l10n.directions,
            onTap: onDirections,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.public_rounded,
            label: l10n.visitWebsite,
            onTap: place.website == null ? null : onWebsite,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _QuickAction(
            icon: Icons.forum_rounded,
            label: l10n.chat,
            onTap: onChat,
          ),
        ),
      ],
    );
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
