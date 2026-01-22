import 'package:shared_preferences/shared_preferences.dart';
import 'token_store_stub.dart';

class _WebStore implements TokenStore {
  static const _key = "jwt_token";

  @override
  Future<void> save(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, token);
  }

  @override
  Future<String?> read() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

TokenStore getTokenStore() => _WebStore();
