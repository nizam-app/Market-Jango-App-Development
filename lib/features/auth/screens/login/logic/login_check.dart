import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/features/driver/screen/driver_home.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/api_control/auth_api.dart';
import '../../../../../core/widget/global_snackbar.dart';
import '../../../../buyer/screens/home_screen.dart';
import '../../../../transport/screens/transport_home.dart';
import '../../../../vendor/screens/vendor_home/screen/vendor_home_screen.dart';

Future<void> loginAndGoSingleRole({
  required BuildContext context,
  required String id,
  required String password,
}) async {
  try {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(AuthAPIController.login),
    );

    request.fields['email'] = id;
    request.fields['password'] = password;

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    Logger().i("🔐 Login Response: $json");

    if (response.statusCode == 200 && json['status'] == 'success') {
      final user = json['data']['user'];
      final token = json['token'];
      final userType = user['user_type'];

      // ✅ Save token & user_type to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      await prefs.setString('user_type', userType);

      GlobalSnackbar.show(
        context,
        title: "Success",
        message: "Login successful!",
        type: CustomSnackType.success,
      );

      // ✅ Navigate according to user_type
      switch (userType.toLowerCase()) {
        case 'buyer':
          context.go(BuyerHomeScreen.routeName);
          break;
        case 'vendor':
          context.go(VendorHomeScreen.routeName);
          break;
        case 'driver':
          context.go(DriverHomeScreen.routeName);
          break;
        case 'transport':
          context.go(TransportHomeScreen.routeName);
          break;
        default:
          GlobalSnackbar.show(context,
              title: "Notice",
              message: "Unknown role: $userType",
              type: CustomSnackType.warning);
      }
    } else {
      throw Exception(json['message'] ?? 'Login failed');
    }
  } catch (e) {
    Logger().e("⛔ Login Error: $e");
    GlobalSnackbar.show(context,
        title: "Error", message: e.toString(), type: CustomSnackType.error);
  }
}
