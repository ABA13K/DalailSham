import 'package:shared_preferences/shared_preferences.dart';

import '../domain/theme_repository.dart';

class SharedPreferencesThemeRepository implements ThemeRepository {
  SharedPreferencesThemeRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'theme_mode';

  @override
  Future<String?> getThemeMode() async => _prefs.getString(_key);

  @override
  Future<void> saveThemeMode(String mode) async => _prefs.setString(_key, mode);
}
