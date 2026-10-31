import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place_category.dart';

/// Sample menus for cafés and restaurants, since the live API has none.
class PlaceMenu extends StatelessWidget {
  const PlaceMenu({super.key, required this.category});

  final PlaceCategory category;

  @override
  Widget build(BuildContext context) {
    final sections = switch (category) {
      PlaceCategory.cafe => _cafeMenu,
      PlaceCategory.restaurant => _restaurantMenu,
      _ => const <_MenuSection>[],
    };
    if (sections.isEmpty) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.restaurant_menu_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.menuTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.menuSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        for (final section in sections) ...[
          _SectionCard(
            section: section,
            localeCode: localeCode,
            currency: l10n.currencySyp,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.section,
    required this.localeCode,
    required this.currency,
  });

  final _MenuSection section;
  final String localeCode;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priceFormat = NumberFormat.decimalPattern(localeCode);

    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(section.icon, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    section.titleFor(localeCode),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            for (final item in section.items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        item.nameFor(localeCode),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 2,
                      child: Text(
                        '${priceFormat.format(item.price)} $currency',
                        textAlign: TextAlign.end,
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection {
  const _MenuSection({
    required this.title,
    required this.titleAr,
    required this.icon,
    required this.items,
  });

  final String title;
  final String titleAr;
  final IconData icon;
  final List<_MenuItem> items;

  String titleFor(String localeCode) => localeCode == 'ar' ? titleAr : title;
}

class _MenuItem {
  const _MenuItem(this.name, this.nameAr, this.price);

  final String name;
  final String nameAr;
  final int price;

  String nameFor(String localeCode) => localeCode == 'ar' ? nameAr : name;
}

const _cafeMenu = [
  _MenuSection(
    title: 'Coffee',
    titleAr: 'قهوة',
    icon: Icons.local_cafe_rounded,
    items: [
      _MenuItem('Espresso', 'إسبريسو', 18000),
      _MenuItem('Turkish coffee', 'قهوة تركية', 15000),
      _MenuItem('Latte', 'لاتيه', 27000),
      _MenuItem('Cappuccino', 'كابتشينو', 25000),
      _MenuItem('Arabic coffee', 'قهوة عربية', 20000),
    ],
  ),
  _MenuSection(
    title: 'Cold drinks',
    titleAr: 'مشروبات باردة',
    icon: Icons.local_drink_rounded,
    items: [
      _MenuItem('Iced latte', 'لاتيه مثلج', 30000),
      _MenuItem('Lemon mint', 'ليمون بالنعناع', 22000),
      _MenuItem('Fresh orange juice', 'عصير برتقال طازج', 25000),
    ],
  ),
  _MenuSection(
    title: 'Desserts',
    titleAr: 'حلويات',
    icon: Icons.cake_rounded,
    items: [
      _MenuItem('Cheesecake', 'تشيز كيك', 35000),
      _MenuItem('Baklava', 'بقلاوة', 28000),
      _MenuItem('Chocolate cake', 'كيكة شوكولاتة', 32000),
    ],
  ),
];

const _restaurantMenu = [
  _MenuSection(
    title: 'Mezze',
    titleAr: 'مقبلات',
    icon: Icons.tapas_rounded,
    items: [
      _MenuItem('Hummus', 'حمص', 20000),
      _MenuItem('Mutabbal', 'متبل', 22000),
      _MenuItem('Fattoush', 'فتوش', 25000),
      _MenuItem('Grape leaves', 'ورق عنب', 30000),
    ],
  ),
  _MenuSection(
    title: 'Grills',
    titleAr: 'مشاوي',
    icon: Icons.outdoor_grill_rounded,
    items: [
      _MenuItem('Shish tawook', 'شيش طاووق', 55000),
      _MenuItem('Kofta kebab', 'كباب كفتة', 60000),
      _MenuItem('Mixed grill', 'مشاوي مشكلة', 95000),
    ],
  ),
  _MenuSection(
    title: 'Main dishes',
    titleAr: 'أطباق رئيسية',
    icon: Icons.dinner_dining_rounded,
    items: [
      _MenuItem('Chicken shawarma plate', 'صحن شاورما دجاج', 45000),
      _MenuItem('Freekeh with chicken', 'فريكة بالدجاج', 40000),
      _MenuItem('Molokhia', 'ملوخية', 35000),
    ],
  ),
  _MenuSection(
    title: 'Drinks',
    titleAr: 'مشروبات',
    icon: Icons.local_drink_rounded,
    items: [
      _MenuItem('Ayran', 'عيران', 10000),
      _MenuItem('Tea', 'شاي', 8000),
      _MenuItem('Soft drink', 'مشروب غازي', 12000),
    ],
  ),
];
