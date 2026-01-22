import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_store_stub.dart';

class _IOStore implements TokenStore {
  static const _storage = FlutterSecureStorage();
  static const _key = "jwt_token";

  @override
  Future<void> save(String token) => _storage.write(key: _key, value: token);

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

TokenStore getTokenStore() => _IOStore();
