import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _k = 'auth_token';
  Future<void> save(String token) async => (await SharedPreferences.getInstance()).setString(_k, token);
  Future<String?> read() async => (await SharedPreferences.getInstance()).getString(_k);
  Future<void> clear() async => (await SharedPreferences.getInstance()).remove(_k);
}
