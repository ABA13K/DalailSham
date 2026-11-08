import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/entities/auth_user.dart';
import '../domain/repositories/account_repository.dart';
import 'models/auth_user_model.dart';

class SharedPreferencesAccountRepository implements AccountRepository {
  SharedPreferencesAccountRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'auth_profile';

  @override
  Future<AuthUser?> getUser() async {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic>
          ? AuthUserModel.fromJson(decoded)
          : null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> saveUser(AuthUser user) =>
      _prefs.setString(_key, jsonEncode(user.toJson()));

  @override
  Future<void> clearUser() => _prefs.remove(_key);
}
