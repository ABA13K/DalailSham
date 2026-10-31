import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../services/domain/entities/service_scope.dart';
import '../../../services/presentation/pages/services_page.dart';
import '../../domain/entities/explore_category.dart';

/// Rectangular category card: image background with name and tagline on top.
class ExploreCategoryCard extends StatelessWidget {
  const ExploreCategoryCard({super.key, required this.category});

  final ExploreCategory category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final imageUrl = category.imageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: () => context.push(
          '/services',
          extra: ServicesRouteArgs(
            scope: ServiceScope.category,
            id: category.id,
            title: category.name,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [scheme.primary, scheme.primaryContainer],
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.category_rounded,
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
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x00000000), Color(0xCC000000)],
                  stops: [0.3, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 14, 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (category.tagline != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      category.tagline!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
