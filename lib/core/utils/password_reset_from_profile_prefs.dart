import 'package:shared_preferences/shared_preferences.dart';

/// When user starts forgot-password flow from logged-in [BuyerProfileEditScreen],
/// persistence tells [ResetPasswordScreen] to navigate to profile tab instead of login.
class PasswordResetFromProfilePrefs {
  PasswordResetFromProfilePrefs._();

  static const keyReturnToProfile = 'password_reset_return_to_profile';
  static const keyShellUserType = 'password_reset_shell_user_type';

  static Future<void> markFlowStarted({required String userType}) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(keyReturnToProfile, true);
    await p.setString(keyShellUserType, userType.toLowerCase().trim());
  }

  /// Returns whether to navigate to shell profile tab, and consumes stored prefs.
  static Future<(bool returnToProfile, String? shellUserType)>
      consumePendingNavigation() async {
    final p = await SharedPreferences.getInstance();
    final want = p.getBool(keyReturnToProfile) ?? false;
    final ut = p.getString(keyShellUserType);
    await p.remove(keyReturnToProfile);
    await p.remove(keyShellUserType);
    return (want, ut != null && ut.isEmpty ? null : ut);
  }
}
