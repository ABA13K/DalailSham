import 'package:shared_preferences/shared_preferences.dart';

import '../domain/token_repository.dart';

class SharedPreferencesTokenRepository implements TokenRepository {
  SharedPreferencesTokenRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'auth_token';

  @override
  Future<String?> getToken() async {
    final token = _prefs.getString(_key);
    return token == null || token.isEmpty ? null : token;
  }

  @override
  Future<void> saveToken(String token) => _prefs.setString(_key, token.trim());

  @override
  Future<void> clearToken() => _prefs.remove(_key);
}
