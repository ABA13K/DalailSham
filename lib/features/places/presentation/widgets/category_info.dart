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
