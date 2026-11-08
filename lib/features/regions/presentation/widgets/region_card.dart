import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/domain/entities/service_scope.dart';
import '../../../services/presentation/pages/services_page.dart';
import '../../domain/entities/region.dart';

/// Rectangular region card matching the "المناطق" home design:
/// image background, top rating pill + heart button, and bottom location pin + name.
class RegionCard extends StatelessWidget {
  const RegionCard({
    super.key,
    required this.region,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  final Region region;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final imageUrl = region.imageUrl;
    final services = region.servicesCount;
    final reviewLabel =
        services != null && services > 0 ? '($services+)' : '(25+)';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(
            '/services',
            extra: ServicesRouteArgs(
              scope: ServiceScope.region,
              id: region.id,
              title: region.name,
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Fallback gradient & icon when image is missing/loading
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [scheme.tertiary, scheme.primaryContainer],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 40,
                    color: scheme.onPrimary.withValues(alpha: 0.6),
                  ),
                ),
              ),
              if (imageUrl != null)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  loadingBuilder: (context, child, progress) =>
                      progress == null ? child : const SizedBox.shrink(),
                ),

              // Bottom dark gradient for text readability
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00000000), Color(0xBD000000)],
                    stops: [0.42, 1.0],
                  ),
                ),
              ),

              // Top row: Rating badge on left, Heart button on right
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Rating pill: ★ 4.5 (25+)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.42),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFC107),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '4.5',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 11,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              reviewLabel,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                                height: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Favorite heart button
                      GestureDetector(
                        onTap: onFavoriteToggle,
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.38),
                          ),
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 16,
                            color: isFavorite ? Colors.redAccent : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom row: Location pin + Region name (Right-aligned in RTL)
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        region.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}