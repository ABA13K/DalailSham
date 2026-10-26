/// Contract for persisting user locale preference.
abstract interface class LocaleRepository {
  Future<String?> getLocaleCode();

  Future<void> saveLocaleCode(String code);
}
