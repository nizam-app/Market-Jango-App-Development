import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// StateNotifier for POST actions that use token
class PostNotifier extends StateNotifier<AsyncValue<bool>> {
  PostNotifier() : super(const AsyncData(false));

  Future<void> send({
    required String keyname,
    required String value,
    required String url,
    required BuildContext context,
  }) async {
    state = const AsyncLoading();

    try {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('auth_token');
      if (token == null || token.isEmpty) throw 'Missing auth token';

      final res = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'token': token,
        },
        body: jsonEncode({keyname: value}),
      );

      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw 'HTTP ${res.statusCode}';
      }

      final j = jsonDecode(res.body);
      final ok = (j is Map &&
          (j['status'] ?? '').toString().toLowerCase() == 'success');
      Logger().i("✅ POST Response: $j");
      if ((j["message"]?? "").toString().toLowerCase() == "otp sent to phone") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Your verification code is: ${j['data']["otp"]}"),
            duration: const Duration(seconds: 15),
            backgroundColor: Colors.blue,
          ),
        );

      }  
      state = AsyncData(ok);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

/// Provider
final postProvider =
StateNotifierProvider<PostNotifier, AsyncValue<bool>>((ref) => PostNotifier());
