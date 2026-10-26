/// Category of a place, derived from OpenStreetMap tags.
enum PlaceCategory {
  restaurant,
  cafe,
  shopping,
  health,
  hotel,
  attraction,
  fuel,
  bank,
  other;

  /// Maps OSM `amenity`/`shop`/`tourism` values to a [PlaceCategory].
  static PlaceCategory fromOsmTags({
    String? amenity,
    String? shop,
    String? tourism,
  }) {
    if (amenity != null) {
      return switch (amenity) {
        'restaurant' || 'fast_food' || 'bar' || 'pub' || 'food_court' =>
          PlaceCategory.restaurant,
        'cafe' || 'ice_cream' => PlaceCategory.cafe,
        'pharmacy' || 'hospital' || 'doctors' || 'clinic' || 'dentist' =>
          PlaceCategory.health,
        'fuel' || 'charging_station' => PlaceCategory.fuel,
        'bank' || 'atm' || 'bureau_de_change' => PlaceCategory.bank,
        _ => PlaceCategory.other,
      };
    }
    if (shop != null) return PlaceCategory.shopping;
    if (tourism != null) {
      return switch (tourism) {
        'hotel' || 'hostel' || 'guest_house' || 'motel' || 'apartment' =>
          PlaceCategory.hotel,
        'attraction' || 'museum' || 'artwork' || 'gallery' || 'viewpoint' ||
        'theme_park' || 'zoo' =>
          PlaceCategory.attraction,
        _ => PlaceCategory.other,
      };
    }
    return PlaceCategory.other;
  }
}
