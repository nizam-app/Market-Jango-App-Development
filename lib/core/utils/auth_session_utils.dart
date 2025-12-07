import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/auth/screens/login/screen/login_screen.dart';
import 'package:market_jango/features/navbar/screen/buyer_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/driver_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';

/// AuthSessionUtils - utility class for managing authentication session
/// 
/// Provides methods to:
/// - Save token + user on login success
/// - Auto-skip login if user is already logged in
/// - Route to the correct home screen based on user_type
/// - Support logout from profile (clear storage + go to login)
class AuthSessionUtils {
  // Singleton instance of AuthLocalStorage
  static final AuthLocalStorage _authStorage = AuthLocalStorage();

  // Route constants
  static const String loginRoute = LoginScreen.routeName;
  static const String splashRoute = '/splashScreen';

  /// Save login data from successful login response
  /// 
  /// Extracts token and user data from the login API response and saves them.
  /// 
  /// [loginResponseJson] - The full login response JSON from the API
  /// Expected structure:
  /// {
  ///   "status": "success",
  ///   "data": {
  ///     "token": "...",
  ///     "user": { ... }  // or "uer"
  ///   }
  /// }
  static Future<void> saveLoginData(Map<String, dynamic> loginResponseJson) async {
    final data = loginResponseJson['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid login response: missing data');
    }

    // Extract token (can be in data or root)
    final token = data['token']?.toString() ?? 
                  loginResponseJson['token']?.toString() ?? '';
    
    if (token.isEmpty) {
      throw Exception('Invalid login response: missing token');
    }

    // Extract user (handle both "user" and "uer" keys)
    final user = data['user'] as Map<String, dynamic>? ?? 
                 data['uer'] as Map<String, dynamic>?;
    
    if (user == null) {
      throw Exception('Invalid login response: missing user data');
    }

    // Save token and user JSON
    await _authStorage.saveLoginData(
      token: token,
      userJson: user,
    );
  }

  /// Check if user is currently logged in
  /// 
  /// Returns true if user has logged in before, false otherwise.
  static Future<bool> isLoggedIn() async {
    return await _authStorage.hasLoggedInBefore();
  }

  /// Get the stored user type
  /// 
  /// Returns the user_type from stored user JSON, or null if not available.
  static Future<String?> getUserType() async {
    final userJson = await _authStorage.getUserJson();
    if (userJson == null) return null;
    
    // Try different possible field names
    final userType = userJson['user_type']?.toString() ?? 
                    userJson['userType']?.toString();
    return userType?.toLowerCase();
  }

  /// Get the route name for the user's home screen based on user_type
  /// 
  /// Returns the appropriate route name, or null if user type is unknown.
  static Future<String?> getHomeRouteForUserType() async {
    final userType = await getUserType();
    if (userType == null) return null;

    switch (userType) {
      case 'buyer':
        return BuyerBottomNavBar.routeName;
      case 'vendor':
        return VendorBottomNav.routeName;
      case 'driver':
        return DriverBottomNavBar.routeName;
      case 'transport':
        return TransportBottomNavBar.routeName;
      default:
        return null;
    }
  }

  /// Handle login button click from splash screen
  /// 
  /// - If user is NOT logged in: navigates to Login screen
  /// - If user is already logged in: navigates directly to their home screen
  ///   based on user_type
  /// 
  /// [context] - BuildContext for navigation
  static Future<void> handleSplashLoginClick(BuildContext context) async {
    final loggedIn = await isLoggedIn();

    if (!loggedIn) {
      // User not logged in - go to login screen
      if (context.mounted) {
        context.go(loginRoute);
      }
    } else {
      // User already logged in - go directly to their home screen
      final homeRoute = await getHomeRouteForUserType();
      if (context.mounted) {
        if (homeRoute != null) {
          context.go(homeRoute);
        } else {
          // Fallback to login if user type is unknown
          context.go(loginRoute);
        }
      }
    }
  }

  /// Auto-navigate based on login status
  /// 
  /// Called on app startup (e.g., from splash screen) to automatically
  /// route the user to the appropriate screen.
  /// 
  /// - If logged in: navigates to home screen based on user_type
  /// - If not logged in: stays on current screen (splash)
  /// 
  /// [context] - BuildContext for navigation
  static Future<void> autoNavigateIfLoggedIn(BuildContext context) async {
    final loggedIn = await isLoggedIn();
    
    if (loggedIn) {
      final homeRoute = await getHomeRouteForUserType();
      if (context.mounted && homeRoute != null) {
        context.go(homeRoute);
      }
    }
  }

  /// Logout user and navigate back to login/splash screen
  /// 
  /// Clears all login data and removes all previous routes from the stack,
  /// then navigates to the login screen.
  /// 
  /// [context] - BuildContext for navigation
  static Future<void> logoutAndGoToLogin(BuildContext context) async {
    // Clear all login data
    await _authStorage.clearLoginData();

    // Navigate to login screen and remove all previous routes
    if (context.mounted) {
      context.go(loginRoute);
    }
  }
}

