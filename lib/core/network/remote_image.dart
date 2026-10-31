/// The API sometimes stores images with a local origin; point those at the
/// public host so devices can load them.
String? normalizeRemoteImageUrl(Object? value) {
  if (value is! String || value.trim().isEmpty) return null;
  final uri = Uri.tryParse(value.trim());
  if (uri == null) return null;
  if (uri.host == '127.0.0.1' || uri.host == 'localhost') {
    return Uri(
      scheme: 'https',
      host: 'dalildimashq.com',
      path: uri.path,
    ).toString();
  }
  return uri.toString();
}
