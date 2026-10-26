/// Tracks whether the user has completed the first-run onboarding.
abstract interface class OnboardingRepository {
  Future<bool> hasCompleted();

  Future<void> markCompleted();
}
