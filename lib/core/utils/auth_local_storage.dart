import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// AuthLocalStorage - handles authentication data persistence
///
/// This class provides methods to save, retrieve, and clear authentication data.
/// It handles both registration tokens and login tokens separately.
/// It uses SharedPreferences internally to persist data.
class AuthLocalStorage {
  // Login token (from login API) - this is the main token after full login
  static const String _loginTokenKey = 'auth_token';

  // Registration token (from registration flow) - temporary token during registration
  static const String _registrationTokenKey = 'registration_token';

  // User data stored after login
  static const String _userJsonKey = 'user_json';
  static const String _hasLoggedInKey = 'has_logged_in';

  // Vendor role data from GET /vendor/my-role
  static const String _vendorRoleKey = 'role';
  static const String _vendorIsOwnerKey = 'is_owner';
  static const String _vendorPermissionsKey = 'permissions';
  static const String _vendorIdKey = 'vendor_id';
  static const String _vendorNameKey = 'vendor_name';

  // Legacy keys (for backward compatibility)
  static const String _legacyUserIdKey = 'user_id';
  static const String _legacyUserTypeKey = 'user_type';

  /// Save login data (token and user JSON) - called after successful login
  Future<void> saveLoginData({
    required String token,
    required Map<String, dynamic> userJson,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // Save login token (this replaces registration token if it exists)
    await prefs.setString(_loginTokenKey, token);
    await prefs.setString(_userJsonKey, jsonEncode(userJson));
    await prefs.setBool(_hasLoggedInKey, true);

    // Extract and save user_id and user_type for backward compatibility
    final userId = userJson['id']?.toString();
    final userType = userJson['user_type']?.toString();

    if (userId != null) {
      await prefs.setString(_legacyUserIdKey, userId);
    }
    if (userType != null) {
      await prefs.setString(_legacyUserTypeKey, userType);
    }

    // Clear registration token after successful login
    await prefs.remove(_registrationTokenKey);
    await _clearVendorRoleData(prefs);
  }

  Future<void> saveVendorRoleData(Map<String, dynamic> roleJson) async {
    final prefs = await SharedPreferences.getInstance();

    final role = roleJson['role']?.toString();
    final isOwner = roleJson['is_owner'];
    final permissions = roleJson['permissions'];
    final vendorId = roleJson['vendor_id'];
    final vendorName = roleJson['vendor_name']?.toString();

    if (role != null && role.isNotEmpty) {
      await prefs.setString(_vendorRoleKey, role);
    }
    if (isOwner is bool) {
      await prefs.setBool(_vendorIsOwnerKey, isOwner);
    } else if (isOwner != null) {
      await prefs.setBool(
        _vendorIsOwnerKey,
        isOwner.toString() == '1' || isOwner.toString().toLowerCase() == 'true',
      );
    }
    if (permissions is Map) {
      await prefs.setString(
        _vendorPermissionsKey,
        jsonEncode(permissions.cast<String, dynamic>()),
      );
    }
    if (vendorId != null) {
      await prefs.setString(_vendorIdKey, vendorId.toString());
    }
    if (vendorName != null && vendorName.isNotEmpty) {
      await prefs.setString(_vendorNameKey, vendorName);
    }
  }

  Future<String?> getVendorRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vendorRoleKey);
  }

  Future<bool> getVendorIsOwner() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vendorIsOwnerKey) ?? false;
  }

  Future<Map<String, dynamic>> getVendorPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vendorPermissionsKey);
    if (raw == null || raw.isEmpty) return const {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) return decoded.cast<String, dynamic>();
    } catch (_) {}
    return const {};
  }

  Future<void> _clearVendorRoleData(SharedPreferences prefs) async {
    await prefs.remove(_vendorRoleKey);
    await prefs.remove(_vendorIsOwnerKey);
    await prefs.remove(_vendorPermissionsKey);
    await prefs.remove(_vendorIdKey);
    await prefs.remove(_vendorNameKey);
  }

  /// Save registration token - called during registration flow
  Future<void> saveRegistrationToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_registrationTokenKey, token);
  }

  /// Get the stored authentication token (login token takes priority)
  /// Returns login token if available, otherwise returns registration token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    // Prefer login token over registration token
    return prefs.getString(_loginTokenKey) ??
        prefs.getString(_registrationTokenKey);
  }

  /// Get login token specifically (not registration token)
  Future<String?> getLoginToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_loginTokenKey);
  }

  /// Get registration token specifically
  Future<String?> getRegistrationToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_registrationTokenKey);
  }

  /// Get the stored user JSON data (only available after login)
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

  /// Get user ID from stored user JSON, or fallback to legacy key
  Future<String?> getUserId() async {
    // First try to get from user JSON (most reliable)
    final userJson = await getUserJson();
    if (userJson != null) {
      final userId = userJson['id']?.toString();
      if (userId != null) return userId;
    }

    // Fallback to legacy key
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_legacyUserIdKey);
  }

  /// Get user type from stored user JSON, or fallback to legacy key
  Future<String?> getUserType() async {
    // First try to get from user JSON (most reliable)
    final userJson = await getUserJson();
    if (userJson != null) {
      final userType = userJson['user_type']?.toString();
      if (userType != null) return userType.toLowerCase();
    }

    // Fallback to legacy key
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_legacyUserTypeKey)?.toLowerCase();
  }

  /// Check if user has logged in before (has login token, not just registration token)
  Future<bool> hasLoggedInBefore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasLoggedInKey) ?? false;
  }

  /// Check if user has a registration token (during registration flow)
  Future<bool> hasRegistrationToken() async {
    final token = await getRegistrationToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all authentication data (both login and registration)
  Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_loginTokenKey);
    await prefs.remove(_registrationTokenKey);
    await prefs.remove(_userJsonKey);
    await prefs.remove(_hasLoggedInKey);
    await _clearVendorRoleData(prefs);
    // Also clear legacy keys
    await prefs.remove(_legacyUserIdKey);
    await prefs.remove(_legacyUserTypeKey);
  }

  /// Clear only registration token (keep login data)
  Future<void> clearRegistrationToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registrationTokenKey);
  }
}
