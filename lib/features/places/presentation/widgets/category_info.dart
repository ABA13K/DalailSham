import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/entities/place_category.dart';

/// Localized labels and icons for [PlaceCategory].
class CategoryInfo {
  CategoryInfo._();

  static IconData icon(PlaceCategory category) => switch (category) {
    PlaceCategory.restaurant => Icons.restaurant_rounded,
    PlaceCategory.cafe => Icons.local_cafe_rounded,
    PlaceCategory.shopping => Icons.shopping_bag_rounded,
    PlaceCategory.health => Icons.local_hospital_rounded,
    PlaceCategory.hotel => Icons.hotel_rounded,
    PlaceCategory.attraction => Icons.museum_rounded,
    PlaceCategory.fuel => Icons.local_gas_station_rounded,
    PlaceCategory.bank => Icons.account_balance_rounded,
    PlaceCategory.other => Icons.place_rounded,
  };

  /// Saturated gradient used by story avatars and story backgrounds.
  static LinearGradient gradient(PlaceCategory category) {
    final colors = switch (category) {
      PlaceCategory.restaurant => [
        const Color(0xFFFF7043),
        const Color(0xFFD84315),
      ],
      PlaceCategory.cafe => [const Color(0xFFA1887F), const Color(0xFF5D4037)],
      PlaceCategory.shopping => [
        const Color(0xFFAB47BC),
        const Color(0xFF6A1B9A),
      ],
      PlaceCategory.health => [
        const Color(0xFF26A69A),
        const Color(0xFF00695C),
      ],
      PlaceCategory.hotel => [const Color(0xFF42A5F5), const Color(0xFF1565C0)],
      PlaceCategory.attraction => [
        const Color(0xFFFFB300),
        const Color(0xFFEF6C00),
      ],
      PlaceCategory.fuel => [const Color(0xFF78909C), const Color(0xFF37474F)],
      PlaceCategory.bank => [const Color(0xFF66BB6A), const Color(0xFF2E7D32)],
      PlaceCategory.other => [const Color(0xFF0D6EFD), const Color(0xFF052A63)],
    };

    return LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static String label(AppLocalizations l10n, PlaceCategory category) =>
      switch (category) {
        PlaceCategory.restaurant => l10n.categoryRestaurant,
        PlaceCategory.cafe => l10n.categoryCafe,
        PlaceCategory.shopping => l10n.categoryShopping,
        PlaceCategory.health => l10n.categoryHealth,
        PlaceCategory.hotel => l10n.categoryHotel,
        PlaceCategory.attraction => l10n.categoryAttraction,
        PlaceCategory.fuel => l10n.categoryFuel,
        PlaceCategory.bank => l10n.categoryBank,
        PlaceCategory.other => l10n.categoryAll,
      };
}
