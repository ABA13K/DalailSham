import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/shimmer.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../cubit/categories_cubit.dart';

/// The category filter of the home feed: one icon pill per section, with the
/// whole city in front of them.
class CategoryPills extends StatelessWidget {
  const CategoryPills({super.key, required this.selectedId, required this.onSelect});

  /// The pressed section, or null while the list holds every place nearby.
  final int? selectedId;
  final ValueChanged<int?> onSelect;

  static const int columns = 3;
  static const double gap = 10;
  static const double iconSize = 54;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        if (state is CategoriesInitial || state is CategoriesLoading) {
          return const _PillsShimmer();
        }
        if (state is! CategoriesReady || state.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsetsDirectional.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.mainCategories,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('categories-see-all'),
                      onPressed: () => context.push('/categories'),
                      child: Text(l10n.seeAll),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width =
                        (constraints.maxWidth - gap * (columns - 1)) / columns;
                    return Wrap(
                      spacing: gap,
                      runSpacing: gap,
                      children: [
                        SizedBox(
                          width: width,
                          child: _Pill(
                            key: const ValueKey('category-pill-all'),
                            label: l10n.categoryAll,
                            icon: Icons.apps_rounded,
                            selected: selectedId == null,
                            onTap: () => onSelect(null),
                          ),
                        ),
                        for (final category in state.categories)
                          SizedBox(
                            width: width,
                            child: _Pill(
                              key: ValueKey('category-pill-${category.id}'),
                              label: category.name,
                              icon: _iconFor(category.name),
                              selected: selectedId == category.id,
                              onTap: () => onSelect(
                                selectedId == category.id ? null : category.id,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The listing carries no icon, so the shape is read out of the section name in
/// either language; anything unrecognised keeps the generic storefront.
IconData _iconFor(String name) {
  final needle = name.toLowerCase();
  bool matches(List<String> words) => words.any(needle.contains);

  if (matches(['cafe', 'coffee', 'كوفي', 'مقه', 'قهوة'])) {
    return Icons.local_cafe_rounded;
  }
  if (matches([
    'restaurant',
    'grill',
    'shawarma',
    'food',
    'مطع',
    'شاورما',
    'مشوي',
    'مأكول',
  ])) {
    return Icons.restaurant_rounded;
  }
  if (matches(['pharmac', 'hospital', 'clinic', 'medical', 'health', 'صيد', 'مشف', 'عياد', 'صحة', 'طبي'])) {
    return Icons.local_hospital_rounded;
  }
  if (matches(['hotel', 'hostel', 'فند', 'شقق'])) {
    return Icons.hotel_rounded;
  }
  if (matches(['fuel', 'petrol', 'gas', 'وقود', 'بنزين', 'محط'])) {
    return Icons.local_gas_station_rounded;
  }
  if (matches(['bank', 'money', 'بنك', 'بنوك', 'صراف', 'حوال'])) {
    return Icons.account_balance_rounded;
  }
  if (matches([
    'attract',
    'landmark',
    'tourism',
    'museum',
    'park',
    'معالم',
    'معلم',
    'سياح',
    'متحف',
    'حدي',
    'قلعة',
  ])) {
    return Icons.park_rounded;
  }
  if (matches([
    'shop',
    'market',
    'store',
    'mall',
    'fashion',
    'سوق',
    'متجر',
    'تسوق',
    'أزياء',
    'مول',
  ])) {
    return Icons.shopping_bag_rounded;
  }
  return Icons.storefront_rounded;
}

class _Pill extends StatelessWidget {
  const _Pill({
    super.key,
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
    final scheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: CategoryPills.iconSize,
              height: CategoryPills.iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? scheme.primary
                    : scheme.primaryContainer.withValues(alpha: 0.55),
              ),
              child: Icon(
                icon,
                size: 25,
                color: selected ? scheme.onPrimary : scheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected
                    ? scheme.primary
                    : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PillsShimmer extends StatelessWidget {
  const _PillsShimmer();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsetsDirectional.fromSTEB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerBox(width: 54, height: 54, borderRadius: 27),
          ShimmerBox(width: 54, height: 54, borderRadius: 27),
          ShimmerBox(width: 54, height: 54, borderRadius: 27),
          ShimmerBox(width: 54, height: 54, borderRadius: 27),
        ],
      ),
    );
  }
}
