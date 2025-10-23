import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final emailRegisterProvider =
StateNotifierProvider<EmailRegisterNotifier, AsyncValue<bool>>(
        (ref) => EmailRegisterNotifier());

class EmailRegisterNotifier extends StateNotifier<AsyncValue<bool>> {
  EmailRegisterNotifier() : super(const AsyncValue.data(false));

  Future<void> registerEmail({
    required String url,
    required String email,
  }) async {
    state = const AsyncValue.loading();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null && token.isNotEmpty) 'token': token,
      });
      request.fields['email'] = email;

      final response = await request.send();
      final body = await response.stream.bytesToString();

      final json = jsonDecode(body);
      Logger().i("📩 Email Register Response: $json");

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          json['status'] == 'success') {
        // ✅ user_type save in SharedPreferences
        final userType = json['data']?['user_type'];
        if (userType != null) {
          await prefs.setString('user_type', userType);
          Logger().i("💾 User Type saved: $userType");
        }

        state = const AsyncValue.data(true);
      } else {
        throw Exception(json['message'] ?? 'Email registration failed');
      }
    } catch (e, st) {
      Logger().e("⛔ Email Register Error: $e");
      state = AsyncValue.error(e, st);
    }
  }
}
