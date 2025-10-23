import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/constants/api_control/auth_api.dart';
import '../screens/reset_password_screen.dart';

Future<void> verifyOtpFunction({
  required BuildContext context,
  required String otp,
}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email') ?? '';

    if (email.isEmpty) {
      throw Exception('Email not found in local storage');
    }

    final url = Uri.parse("${AuthAPIController.verifyOtp}?otp=$otp&email=$email");
    final request = http.MultipartRequest('POST', url);
    request.fields['otp'] = otp;

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final json = jsonDecode(body);

    Logger().i("📩 Verify OTP Response: $json");

    if (response.statusCode == 200 && json['status'] == 'success') {
      GlobalSnackbar.show(
        context,
        title: "Success",
        message: json['message'] ?? "OTP verified successfully!",
        type: CustomSnackType.success,
      );

      // ✅ Extract token safely from nested data
      final token = json['data']?['token']?.toString() ?? '';

      if (token.isNotEmpty) {
        await prefs.setString('auth_token', token);
        Logger().i("🔑 Token saved: $token");
      } else {
        Logger().w("⚠️ Token missing in API response (json['data']['token'] is null)");
      }

      // ✅ Navigate to new password screen
      context.push(ResetPasswordScreen.routeName);
    } else {
      throw Exception(json['message'] ?? 'Verification failed');
    }
  } catch (e, st) {
    Logger().e("⛔ OTP Verify Error: $e", error: e, stackTrace: st);
    GlobalSnackbar.show(
      context,
      title: "Error",
      message: e.toString(),
      type: CustomSnackType.error,
    );
  }
}
