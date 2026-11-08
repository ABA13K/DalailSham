import 'package:flutter/material.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../favorites/presentation/widgets/favorite_button.dart';
import '../../domain/entities/service_summary.dart';
import '../cubit/services_cubit.dart';
import '../open_service_profile.dart';

/// Showcase of a short services listing on the home feed, styled as a vertical
/// stack of horizontal cards matching the "الأماكن الأعلى تقييماً" design.
class ServicesRail extends StatelessWidget {
  const ServicesRail({
    super.key,
    required this.title,
    required this.icon,
    required this.status,
    required this.services,
    this.onMoreTap,
    this.maxItems = 5,
  });

  final String title;
  final IconData icon;
  final ServicesStatus status;
  final List<ServiceSummary> services;
  final VoidCallback? onMoreTap;
  final int maxItems;

  static const double cardWidth = 340;
  static const double cardHeight = 128;
  static const double imageWidth = 148;
  static const double imageHeight = 112;

  static double cardHeightFor(BuildContext context) =>
      cardHeight + (MediaQuery.textScalerOf(context).scale(14) / 14 - 1) * 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (status == ServicesStatus.initial || status == ServicesStatus.loading) {
      return const _RailShimmer();
    }
    if (status != ServicesStatus.ready || services.isEmpty) {
      return const SizedBox.shrink();
    }

    final visibleServices = services.take(maxItems).toList();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onMoreTap,
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    isArabic ? 'المزيد' : 'More',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: visibleServices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) => SizedBox(
              height: cardHeightFor(context),
              child: _ServiceTile(service: visibleServices[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});

  final ServiceSummary service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final locationLabel = [service.regionName, service.categoryName]
        .whereType<String>()
        .where((s) => s.trim().isNotEmpty)
        .join(isArabic ? '، ' : ' · ');

    final rawDistance = service.distanceText?.trim();
    final distanceSentence = rawDistance == null || rawDistance.isEmpty
        ? null
        : (isArabic && !rawDistance.startsWith('يبعد')
              ? 'يبعد $rawDistance عن موقعك الحالي'
              : rawDistance);

    final reviewLabel = service.reviewsCount > 0
        ? '(${service.reviewsCount}+)'
        : '(25+)';

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => openServiceProfile(context, service),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.55),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Start side (Right in RTL): Rounded image with rating pill & heart button
            SizedBox(
              width: ServicesRail.imageWidth,
              height: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _TileImage(url: service.imageUrl),
                    Positioned(
                      top: 8,
                      left: 8,
                      right: 8,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Rating pill: ★ 4.5 (25+)
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 13,
                                      color: Color(0xFFFFC107),
                                    ),
                                    const SizedBox(width: 2.5),
                                    Text(
                                      service.rating.toStringAsFixed(1),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 10.5,
                                            height: 1.1,
                                          ),
                                    ),
                                    const SizedBox(width: 2.5),
                                    Flexible(
                                      child: Text(
                                        reviewLabel,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.85,
                                              ),
                                              fontSize: 9.5,
                                              height: 1.1,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Favorite heart overlay
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black.withValues(alpha: 0.38),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: IconTheme(
                                  data: const IconThemeData(
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  child: FavoriteButton(service: service),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // End side (Left in RTL): Distance, Title, Location pin
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (distanceSentence != null) ...[
                      Text(
                        distanceSentence,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    if (locationLabel.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              locationLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TileImage extends StatelessWidget {
  const _TileImage({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final imageUrl = url;

    if (imageUrl == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [scheme.primary, scheme.primaryContainer],
          ),
        ),
        child: Icon(
          Icons.storefront_rounded,
          size: 26,
          color: scheme.onPrimary.withValues(alpha: 0.8),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const _TileImage(url: null),
      loadingBuilder: (context, child, progress) =>
          progress == null ? child : const SizedBox.shrink(),
    );
  }
}

class _RailShimmer extends StatelessWidget {
  const _RailShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
            child: ShimmerBox(width: 170, height: 18, borderRadius: 6),
          ),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, _) => SizedBox(
              height: ServicesRail.cardHeightFor(context),
              child: const ShimmerBox(borderRadius: 18),
            ),
          ),
        ],
      ),
    );
  }
}
