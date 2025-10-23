import 'global_api.dart';

class AuthAPIController {
 static String _base_api = "$api/api";
 static String login = "$_base_api/login";
  static String registerTypeSelection = "${_base_api}/register-type";
  static String registerName= "${_base_api}/register-name";
  static String registerPhone= "${_base_api}/register-phone";
  static String registerEmail= "${_base_api}/register-email";
  static String registerVendorRequestStore= "${_base_api}/vendor/register";
  static String business_type= "${_base_api}/business-type";
  static String registerDriverCarInfo="${_base_api}/driver/register";
  static String phoneVerifyOtp="${_base_api}/user-verify-otp";
  static String resetPassword="${_base_api}/reset-password";
  static String registerPassword="${_base_api}/register-password";
  static String forgetPassword="${_base_api}/forget-password";
  static String verifyOtp="${_base_api}/verify-mail-otp";
  static String route="${_base_api}/route";
}
