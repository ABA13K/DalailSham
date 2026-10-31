/// The grouping a services listing is scoped to.
enum ServiceScope {
  /// Services published inside a category (`/categories/{id}/services`).
  category,

  /// Services published inside a region (`/regions/{id}/services`).
  region,
}
