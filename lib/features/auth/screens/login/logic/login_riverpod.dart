import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../../../../../core/constants/api_control/auth_api.dart';
import '../../../../../core/constants/api_control/vendor_api.dart';
import '../../../../../core/utils/auth_header_provider.dart';
import '../../../../../core/utils/auth_local_storage.dart';
import '../../../../../core/utils/auth_session_utils.dart';
import '../../../../../core/utils/get_token_sharedpefarens.dart';
import '../../../../../core/utils/get_user_type.dart';
import '../../../../../core/widget/global_snackbar.dart';

// Login state provider
final loginStateProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, AsyncValue<void>>(
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
      final response = await _performLoginRequest(email, password).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException(
            'Login request timed out. Please check your connection.',
          );
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

    // 🔥 Invalidate token and user providers to refresh them with new data
    // This ensures that when the home screen loads, it has the latest token
    ref.invalidate(authTokenProvider);
    ref.invalidate(getUserTypeProvider);
    ref.invalidate(getUserIdProvider);
    ref.invalidate(getUserEmailProvider);
    ref.invalidate(authHeadersProvider);

    // ✅ Wait for token provider to actually refresh and have a value
    // This ensures token is ready before navigation, preventing first-load data issues
    try {
      final token = await ref.read(authTokenProvider.future);
      if (token == null || token.isEmpty) {
        Logger().w("⚠️ Token not ready after login, waiting...");
        await Future.delayed(const Duration(milliseconds: 300));
        final retryToken = await ref.read(authTokenProvider.future);
        if (retryToken == null || retryToken.isEmpty) {
          throw Exception('Token not available after login');
        }
      }
    } catch (e) {
      Logger().e("⛔ Error waiting for token: $e");
      // Continue anyway, but log the error
    }

    // Get user type for logging and navigation
    final userType = await AuthSessionUtils.getUserType();
    Logger().i("💡 🔐 Login successful for user type: $userType");

    if (userType == 'vendor') {
      await _fetchAndSaveVendorRole();
      ref.invalidate(vendorRoleProvider);
      ref.invalidate(vendorPermissionsProvider);
      ref.invalidate(isVendorOwnerProvider);
      ref.invalidate(canViewStaffManagementProvider);
      ref.invalidate(canCreateOrDeleteStaffProvider);
      ref.invalidate(canUpdateStaffRoleProvider);
      ref.invalidate(canManageProductsProvider);
      ref.invalidate(canManageOrdersProvider);
      ref.invalidate(canHandleReviewsReportsProvider);
    }

    if (!context.mounted) return;

    GlobalSnackbar.show(
      context,
      title: "Success",
      message: "Login successful!",
      type: CustomSnackType.success,
    );

    // Navigate based on user type
    final homeRoute = await AuthSessionUtils.getHomeRouteForUserType();
    if (!context.mounted) return;

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

  Future<void> _fetchAndSaveVendorRole() async {
    final headers = await ref.read(authHeadersProvider.future);
    final uri = Uri.parse(VendorAPIController.vendorMyRole);
    final response = await http
        .get(uri, headers: headers)
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException('Vendor role request timed out');
          },
        );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Unable to load vendor role: HTTP ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid vendor role response');
    }

    final data = decoded['data'];
    final roleJson = data is Map
        ? data.cast<String, dynamic>()
        : decoded.cast<String, dynamic>();

    await AuthLocalStorage().saveVendorRoleData(roleJson);
  }
}
