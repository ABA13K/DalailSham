import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place_category.dart';
import 'category_info.dart';

/// Horizontally scrollable category filter chips.
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

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              label: Text(l10n.categoryAll),
              selected: selected == null,
              onSelected: (_) => onSelected(null),
            ),
          ),
          for (final category in PlaceCategory.values)
            if (category != PlaceCategory.other)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 8),
                child: ChoiceChip(
                  avatar: Icon(
                    CategoryInfo.icon(category),
                    size: 18,
                    color: selected == category
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  label: Text(CategoryInfo.label(l10n, category)),
                  selected: selected == category,
                  onSelected: (_) => onSelected(category),
                ),
              ),
        ],
      ),
    );
  }
}
