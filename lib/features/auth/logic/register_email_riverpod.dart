import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

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
      final authStorage = AuthLocalStorage();
      final token = await authStorage.getToken();

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
        // ✅ user_type is saved via AuthLocalStorage when login data is saved
        // No need to save separately here

        state = const AsyncValue.data(true);
      } else {
        // Show "Your email is already registered" for validation errors
        throw Exception('Your email is already registered');
      }
    } catch (e, st) {
      Logger().e("⛔ Email Register Error: $e");
      state = AsyncValue.error(e, st);
    }
  }
}
