/// Tracks whether the user has seen the in-app guided tour.
abstract interface class TutorialRepository {
  Future<bool> hasCompleted();

  Future<void> setCompleted(bool completed);
}
