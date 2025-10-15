import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final verifyOtpProvider =
StateNotifierProvider<VerifyOtpNotifier, AsyncValue<bool>>(
        (ref) => VerifyOtpNotifier());

class VerifyOtpNotifier extends StateNotifier<AsyncValue<bool>> {
  VerifyOtpNotifier() : super(const AsyncValue.data(false));

  Future<void> verifyOtp({
    required String url,
    required String otp,
  }) async {
    state = const AsyncValue.loading();
    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');
      if (token == null || token.isEmpty) throw 'Missing auth token';

      final req = http.MultipartRequest('POST', Uri.parse(url));
      req.headers.addAll({
        'Accept': 'application/json',
        'token': token,
      });
      req.fields['otp'] = otp;

      final res = await req.send();
      final body = await res.stream.bytesToString();

      final j = jsonDecode(body);
      if (res.statusCode == 200 && j['status'] == 'success') {
        // ✅ optional: token / user info save করতে পারো
        state = const AsyncValue.data(true);
      } else {
        throw j['message'] ?? 'OTP verification failed';
      }
    } catch (e, st) {
      Logger().e('⛔ Verify OTP Error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}
