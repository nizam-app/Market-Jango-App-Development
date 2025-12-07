// user_by_id_provider.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/profile_model.dart';

// এখন userProvider id নেবে, api থেকে user + images নিয়ে আসবে
final userProvider = FutureProvider.family<UserModel, String>((
  ref,
  String userId,
) async {
  final prefs = await SharedPreferences.getInstance();

  final token = prefs.getString("auth_token");
  if (token == null) {
    throw Exception("auth token not found");
  }

  final uri = Uri.parse("${AuthAPIController.user_show}?id=$userId");

  final response = await http.get(
    uri,
    headers: {"Accept": "application/json", "token": token},
  );

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body) as Map<String, dynamic>;

    // data object নাও
    final data = body['data'] as Map<String, dynamic>?;

    if (data == null) {
      throw Exception("Invalid response: data is null");
    }

    // user আর images আলাদা করো
    final userJson = Map<String, dynamic>.from(
      data['user'] as Map<String, dynamic>? ?? {},
    );

    final imagesJson = (data['images'] as List?) ?? [];

    userJson['user_images'] = imagesJson;

    // এখন merged map থেকে model বানাও
    return UserModel.fromJson(userJson);
  } else {
    throw Exception("Failed to load user (${response.statusCode})");
  }
});
