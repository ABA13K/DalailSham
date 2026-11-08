/// The grouping a services listing is scoped to.
enum ServiceScope {
  /// Services published inside a category (`/categories/{id}/services`).
  category,

  /// Services published inside a region (`/regions/{id}/services`).
  region,

  /// Services the signed-in user favorited (`/favorites/services`).
  favorites,

  /// The ten best rated services (`/services/top-ten`).
  topRated,

  /// The ten services closest to the sent location (`/services/nearby`), or ten
  /// picked at random when no location travels.
  nearby,
}
