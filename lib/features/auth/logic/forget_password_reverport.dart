import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/widget/global_snackbar.dart';
import '../screens/forget_otp_verification_screen.dart';

final forgetPasswordProvider =
StateNotifierProvider<ForgetPasswordNotifier, AsyncValue<bool>>(
      (ref) => ForgetPasswordNotifier(),
);

class ForgetPasswordNotifier extends StateNotifier<AsyncValue<bool>> {
  ForgetPasswordNotifier() : super(const AsyncValue.data(false));

  Future<void> sendForgetPassword({
    required BuildContext context,
    required String email,
  }) async {
    state = const AsyncValue.loading();

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(AuthAPIController.forgetPassword),
      );
      request.fields['email'] = email;

      final response = await request.send();
      final body = await response.stream.bytesToString();
      final json = jsonDecode(body);

      Logger().i("📧 Forget Password Response: $json");

      if (response.statusCode == 200 && json['status'] == 'success') {
        state = const AsyncValue.data(true);

        // ✅ Save email to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('email', email);

        GlobalSnackbar.show(
          context,
          title: "Success",
          message: json['message'] ?? "OTP sent successfully!",
          type: CustomSnackType.success,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Your verification code is: ${json['data'].toString()}"),
            duration: const Duration(seconds: 15),
            backgroundColor: Colors.blue,
          ),
        );


        context.push(ForgetOTPVerificationScreen.routeName, extra: json['data']);
      } else {
        throw Exception(json['message'] ?? 'Request failed');
      }
    } catch (e, st) {
      Logger().e("⛔ Forget Password Error: $e");
      state = AsyncValue.error(e, st);

      GlobalSnackbar.show(
        context,
        title: "Error",
        message: e.toString(),
        type: CustomSnackType.error,
      );
    }
  }
}
