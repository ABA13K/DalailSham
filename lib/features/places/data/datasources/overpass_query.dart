/// Builds an Overpass QL query for places within [radiusMeters] of a point.
///
/// Only meaningful POI tags are requested, and the result is capped so the
/// UI stays fast on mobile connections.
String buildOverpassQuery({
  required double latitude,
  required double longitude,
  required int radiusMeters,
  int limit = 80,
}) {
  final around = '(around:$radiusMeters,$latitude,$longitude)';
  const amenityPattern =
      r'^(restaurant|fast_food|cafe|bar|pub|pharmacy|hospital|doctors|clinic|fuel|bank|atm)$';
  const tourismPattern =
      r'^(hotel|hostel|guest_house|motel|attraction|museum|artwork|gallery|viewpoint|theme_park|zoo)$';

  return '''
[out:json][timeout:25];
(
  node["amenity"~"$amenityPattern"]$around;
  way["amenity"~"$amenityPattern"]$around;
  node["shop"]$around;
  node["tourism"~"$tourismPattern"]$around;
  way["tourism"~"$tourismPattern"]$around;
);
out body $limit;
''';
}
