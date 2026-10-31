import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place.dart';
import 'category_info.dart';
import 'place_logo_mark.dart';

/// Full-screen company image shown when the profile photo is opened.
class PlacePhotoView extends StatelessWidget {
  const PlacePhotoView({super.key, required this.place, required this.initial});

  final Place place;
  final String initial;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;
    final gradient = CategoryInfo.gradient(place.category);

    return DecoratedBox(
      key: const ValueKey('profile-photo'),
      decoration: BoxDecoration(gradient: gradient),
      child: Stack(
        fit: StackFit.expand,
        clipBehavior: Clip.hardEdge,
        children: [
          PositionedDirectional(
            top: -70,
            end: -60,
            child: _Glow(size: 280, opacity: 0.12),
          ),
          PositionedDirectional(
            bottom: -80,
            start: -70,
            child: _Glow(size: 240, opacity: 0.08),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlaceLogoMark(
                    size: 148,
                    initial: initial,
                    gradient: gradient,
                    icon: CategoryInfo.icon(place.category),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    place.displayNameFor(localeCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CategoryInfo.label(l10n, place.category),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.profilePhoto,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  const _Glow({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
