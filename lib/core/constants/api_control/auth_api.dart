import 'global_api.dart';

class AuthAPIController {
 static String _base_api = "$api/api";
  static String registerTypeSelection = "${_base_api}/register-type";
  static String registerName= "${_base_api}/register-name";
  static String registerPhone= "${_base_api}/register-phone";
  static String registerEmail= "${_base_api}/register-email";
  static String registerVendorRequestStore= "${_base_api}/vendor/register";
  static String registerDriverCarInfo="${_base_api}/driver/register";
  static String phoneVerifyOtp="${_base_api}/user-verify-otp";

  // static String userSignUp = "${_base_api}/signup";
}
