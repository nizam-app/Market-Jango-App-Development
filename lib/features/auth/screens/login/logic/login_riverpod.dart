import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../../../core/constants/api_control/auth_api.dart';
import '../../../../../core/utils/auth_session_utils.dart';
import '../../../../../core/widget/global_snackbar.dart';

// Login state provider
final loginStateProvider = StateNotifierProvider.autoDispose<LoginNotifier, AsyncValue<void>>(
  (ref) => LoginNotifier(ref),
);

class LoginNotifier extends StateNotifier<AsyncValue<void>> {
  LoginNotifier(this.ref) : super(const AsyncValue.data(null));
  final Ref ref;

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    try {
      // Network call with timeout
      final response = await _performLoginRequest(email, password)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Login request timed out. Please check your connection.');
            },
          );

      // Parse JSON in isolate if response is large, otherwise on main thread
      final json = await _parseJsonInIsolate(response);

      if (json['status'] == 'success') {
        // Process response and save data
        await _processLoginResponse(json, context);
        state = const AsyncValue.data(null);
      } else {
        final errorMessage = json['message'] ?? 'Login failed';
        state = AsyncValue.error(errorMessage, StackTrace.current);
        GlobalSnackbar.show(
          context,
          title: "Error",
          message: errorMessage,
          type: CustomSnackType.error,
        );
      }
    } on TimeoutException catch (e, st) {
      state = AsyncValue.error(e, st);
      GlobalSnackbar.show(
        context,
        title: "Timeout",
        message: e.message ?? 'Request timed out',
        type: CustomSnackType.error,
      );
    } catch (e, st) {
      Logger().e("⛔ Login Error: $e");
      state = AsyncValue.error(e, st);
      GlobalSnackbar.show(
        context,
        title: "Error",
        message: e.toString().replaceAll('Exception: ', ''),
        type: CustomSnackType.error,
      );
    }
  }

  Future<String> _performLoginRequest(String email, String password) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(AuthAPIController.login),
    );

    request.fields['email'] = email;
    request.fields['password'] = password;

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 25),
      onTimeout: () {
        throw TimeoutException('Network request timed out');
      },
    );

    if (streamedResponse.statusCode != 200) {
      throw Exception('HTTP ${streamedResponse.statusCode}');
    }

    final body = await streamedResponse.stream.bytesToString().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        throw TimeoutException('Reading response timed out');
      },
    );

    return body;
  }

  Future<Map<String, dynamic>> _parseJsonInIsolate(String jsonString) async {
    // Use compute for large JSON to move parsing off main thread
    if (jsonString.length > 10000) {
      return await compute(_parseJson, jsonString);
    }
    // For smaller JSON, parse on main thread (fast enough)
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  // Top-level function for compute
  static Map<String, dynamic> _parseJson(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  Future<void> _processLoginResponse(
    Map<String, dynamic> json,
    BuildContext context,
  ) async {
    // Save login data using AuthSessionUtils
    await AuthSessionUtils.saveLoginData(json);

    // Get user type for logging and navigation
    final userType = await AuthSessionUtils.getUserType();
    Logger().i("💡 🔐 Login successful for user type: $userType");

    GlobalSnackbar.show(
      context,
      title: "Success",
      message: "Login successful!",
      type: CustomSnackType.success,
    );

    // Navigate based on user type
    if (!context.mounted) return;

    final homeRoute = await AuthSessionUtils.getHomeRouteForUserType();
    if (homeRoute != null) {
      context.go(homeRoute);
    } else {
      GlobalSnackbar.show(
        context,
        title: "Notice",
        message: "Unknown or missing user type: $userType",
        type: CustomSnackType.warning,
      );
    }
  }
}

