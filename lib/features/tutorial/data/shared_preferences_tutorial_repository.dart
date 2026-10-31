import 'package:shared_preferences/shared_preferences.dart';

import '../domain/tutorial_repository.dart';

class SharedPreferencesTutorialRepository implements TutorialRepository {
  SharedPreferencesTutorialRepository(this._preferences);

  static const _completedKey = 'tutorial_completed';

  final SharedPreferences _preferences;

  @override
  Future<bool> hasCompleted() async =>
      _preferences.getBool(_completedKey) ?? false;

  @override
  Future<void> setCompleted(bool completed) async {
    await _preferences.setBool(_completedKey, completed);
  }
}
