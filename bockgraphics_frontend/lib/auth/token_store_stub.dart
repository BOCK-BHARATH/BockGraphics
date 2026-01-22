abstract class TokenStore {
  Future<void> save(String token);
  Future<String?> read();
  Future<void> clear();
}

TokenStore getTokenStore() =>
    throw UnsupportedError("TokenStore not supported on this platform");
