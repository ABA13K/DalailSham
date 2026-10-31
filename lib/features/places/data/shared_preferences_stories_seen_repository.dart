import 'package:shared_preferences/shared_preferences.dart';

import '../domain/repositories/stories_seen_repository.dart';

class SharedPreferencesStoriesSeenRepository implements StoriesSeenRepository {
  SharedPreferencesStoriesSeenRepository(this._preferences);

  static const _viewedKey = 'viewed_story_ids';

  final SharedPreferences _preferences;

  @override
  Future<Set<String>> getViewedIds() async =>
      (_preferences.getStringList(_viewedKey) ?? const []).toSet();

  @override
  Future<void> saveViewedIds(Set<String> ids) async {
    await _preferences.setStringList(_viewedKey, ids.toList());
  }
}
