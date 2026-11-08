/// How the backend orders a search, spelled the way the `sort` parameter
/// spells it.
enum ServiceSort {
  latest('latest'),
  rating('rating'),
  distance('distance');

  const ServiceSort(this.wire);

  final String wire;
}
