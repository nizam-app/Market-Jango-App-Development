import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/features/navbar/screen/buyer_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/driver_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/transport_bottom_nav_bar.dart';
import 'package:market_jango/features/navbar/screen/vendor_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../core/constants/api_control/auth_api.dart';
import '../../../../../core/widget/global_snackbar.dart';

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

    Logger().i("💡 🔐 Login Response: $json");

    if (response.statusCode == 200 && json['status'] == 'success') {
      final data = json['data'];

      // 🔥 Handle both “user” and “uer” key safely
      final user = data['user'] ?? data['uer'];

      if (user == null) {
        throw Exception("Invalid response: user data not found");
      }

      final userType = user['user_type'] ?? '';
      final token = data['token'] ?? json['token'] ?? '';
      final int id = user['id'];

      // ✅ Save token & user_type safely
      final prefs = await SharedPreferences.getInstance();
      if (token.isNotEmpty) await prefs.setString('auth_token', token);
      if (userType.isNotEmpty) await prefs.setString('user_type', userType);
      if (id != null) await prefs.setString('user_id', id.toString());

      GlobalSnackbar.show(
        context,
        title: "Success",
        message: "Login successful!",
        type: CustomSnackType.success,
      );

      // ✅ Role-based navigation
      switch (userType.toLowerCase()) {
        case 'buyer':
          context.go(BuyerBottomNavBar.routeName);
          break;
        case 'vendor':
          context.go(VendorBottomNav.routeName);
          break;
        case 'driver':
          context.go(DriverBottomNavBar.routeName);
          break;
        case 'transport':
          context.go(TransportBottomNavBar.routeName);
          break;
        default:
          GlobalSnackbar.show(
            context,
            title: "Notice",
            message: "Unknown or missing user type: $userType",
            type: CustomSnackType.warning,
          );
      }
    } else {
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: json['message'] ?? 'Login failed',
        type: CustomSnackType.error,
      );
      throw Exception(json['message'] ?? 'Login failed');

    }
  } catch (e, st) {
    Logger().e("⛔ Login Error: $e");
    GlobalSnackbar.show(
      context,
      title: "Error",
      message: e.toString(),
      type: CustomSnackType.error,
    );
  }
}
