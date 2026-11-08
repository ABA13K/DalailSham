/// Contract for persisting the bearer token used by authenticated endpoints.
abstract interface class TokenRepository {
  Future<String?> getToken();

  Future<void> saveToken(String token);

  Future<void> clearToken();
}
