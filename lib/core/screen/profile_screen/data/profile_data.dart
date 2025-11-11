// user_by_id_provider.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/profile_model.dart';

// just make userProvider accept an id parameter
final userProvider = FutureProvider.family<UserModel, String>((
  ref,
  String userId,
) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();

  String? _auth_token = _sharedPreferences.getString("auth_token");
  if (_auth_token == null) {
    throw Exception("auth token not found");
  }

  final response = await http.get(
    Uri.parse("${AuthAPIController.user_show}?id=$userId"),
    headers: {"token": _auth_token},
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return UserModel.fromJson(json['data']);
  } else {
    throw Exception("Failed to load user");
  }
});
