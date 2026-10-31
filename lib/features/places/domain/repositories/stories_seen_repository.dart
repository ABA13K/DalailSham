/// Persists which place stories the user has already watched.
abstract interface class StoriesSeenRepository {
  Future<Set<String>> getViewedIds();

  Future<void> saveViewedIds(Set<String> ids);
}
