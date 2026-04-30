import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../../../../core/constants/api_control/auth_api.dart';
import '../../../../../core/utils/auth_session_utils.dart';
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

    final t = id.trim();
    if (t.contains('@')) {
      request.fields['email'] = t.toLowerCase();
    } else {
      request.fields['phone'] = t.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    }
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

      // ✅ Save login data using AuthSessionUtils (handles token + user JSON)
      await AuthSessionUtils.saveLoginData(json);

      GlobalSnackbar.show(
        context,
        title: "Success",
        message: "Login successful!",
        type: CustomSnackType.success,
      );

      // ✅ Role-based navigation using AuthSessionUtils
      final homeRoute = await AuthSessionUtils.getHomeRouteForUserType();
      if (homeRoute != null) {
        context.go(homeRoute);
      } else {
        final userType = await AuthSessionUtils.getUserType();
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
        message: "Invalid email, phone, or password",
        type: CustomSnackType.error,
      );
      throw Exception("Invalid email, phone, or password");

    }
  } catch (e) {
    Logger().e("⛔ Login Error: $e");
    GlobalSnackbar.show(
      context,
      title: "Error",
      message: "Invalid email, phone, or password",
      type: CustomSnackType.error,
    );
  }
}
