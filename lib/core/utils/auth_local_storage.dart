import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthLocalStorage - handles authentication data persistence
/// 
/// This class provides methods to save, retrieve, and clear login data.
/// It uses SharedPreferences internally to persist data.
class AuthLocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userJsonKey = 'user_json';
  static const String _hasLoggedInKey = 'has_logged_in';

  /// Save login data (token and user JSON)
  Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userJsonKey, jsonEncode(userJson));
    await prefs.setBool(_hasLoggedInKey, true);
  }

  /// Get the stored authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get the stored user JSON data
  Future<Map<String, dynamic>?> getUserJson() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString(_userJsonKey);
    if (userJsonString == null) return null;
    try {
      return jsonDecode(userJsonString) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check if user has logged in before
  Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasLoggedInKey) ?? false;
  }

  /// Clear all login data
  Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userJsonKey);
    await prefs.remove(_hasLoggedInKey);
    // Also clear legacy keys if they exist
    await prefs.remove('user_type');
    await prefs.remove('user_id');
  }
}

