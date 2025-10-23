
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final resetPasswordProvider =
StateNotifierProvider<ResetPasswordNotifier, AsyncValue<bool>>(
      (ref) => ResetPasswordNotifier(),
);

class ResetPasswordNotifier extends StateNotifier<AsyncValue<bool>> {
  ResetPasswordNotifier() : super(const AsyncValue.data(false));

  Future<void> resetPassword({
    required String url,
    required String password,
    required String confirmPassword,
  }) async {
    state = const AsyncValue.loading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      });

      request.fields['password'] = password;
      request.fields['password_confirmation'] = confirmPassword;

      final response = await request.send();
      final body = await response.stream.bytesToString();
      Logger().i("🔐 Reset Password Response: $body");

      final json = jsonDecode(body);

      if (response.statusCode == 200 && json['status'] == 'success') {
        state = const AsyncValue.data(true);
      } else {
        throw Exception(json['message'] ?? 'Password reset failed');
      }
    } catch (e, st) {
      Logger().e("⛔ Reset Password Error: $e");
      state = AsyncValue.error(e, st);
    }
  }
}
