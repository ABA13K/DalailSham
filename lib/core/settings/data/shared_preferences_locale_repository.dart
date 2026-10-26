import 'package:shared_preferences/shared_preferences.dart';

import '../domain/locale_repository.dart';

class SharedPreferencesLocaleRepository implements LocaleRepository {
  SharedPreferencesLocaleRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'locale_code';

  @override
  Future<String?> getLocaleCode() async => _prefs.getString(_key);

  @override
  Future<void> saveLocaleCode(String code) async => _prefs.setString(_key, code);
}
