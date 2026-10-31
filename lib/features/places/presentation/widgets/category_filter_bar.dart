import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place_category.dart';
import 'category_info.dart';

/// Horizontally scrollable category filter pills.
class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PlaceCategory? selected;
  final ValueChanged<PlaceCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    Widget pill({
      Key? key,
      required String label,
      required IconData icon,
      required bool isSelected,
      required VoidCallback onTap,
    }) => Padding(
      key: key,
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: _CategoryPill(
        label: label,
        icon: icon,
        selected: isSelected,
        onTap: onTap,
      ),
    );

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          pill(
            key: const ValueKey('category-all'),
            label: l10n.categoryAll,
            icon: Icons.apps_rounded,
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          for (final category in PlaceCategory.values)
            if (category != PlaceCategory.other)
              pill(
                key: ValueKey('category-${category.name}'),
                label: CategoryInfo.label(l10n, category),
                icon: CategoryInfo.icon(category),
                isSelected: selected == category,
                onTap: () => onSelected(category),
              ),
        ],
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = selected
        ? Colors.white
        : theme.colorScheme.onSurfaceVariant;

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: selected
              ? const LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: [AppTheme.brand, AppTheme.brandDeep],
                )
              : null,
          color: selected ? null : theme.colorScheme.surfaceContainerHighest,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppTheme.brand.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: foreground),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
