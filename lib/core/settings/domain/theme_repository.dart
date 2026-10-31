/// Contract for persisting the user's theme preference.
abstract interface class ThemeRepository {
  /// One of `system`, `light` or `dark`, or null when not chosen yet.
  Future<String?> getThemeMode();

  Future<void> saveThemeMode(String mode);
}
