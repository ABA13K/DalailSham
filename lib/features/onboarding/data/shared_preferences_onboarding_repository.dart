import 'package:shared_preferences/shared_preferences.dart';

import '../domain/onboarding_repository.dart';

class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  SharedPreferencesOnboardingRepository(this._preferences);

  static const _completedKey = 'onboarding_completed';

  final SharedPreferences _preferences;

  @override
  Future<bool> hasCompleted() async =>
      _preferences.getBool(_completedKey) ?? false;

  @override
  Future<void> markCompleted() async {
    await _preferences.setBool(_completedKey, true);
  }
}
