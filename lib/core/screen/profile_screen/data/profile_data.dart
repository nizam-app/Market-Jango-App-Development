import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/profile_model.dart';

final userProvider = FutureProvider<UserModel>((ref) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  String? _user_id = _sharedPreferences.getString("user_id");
  if (_user_id == null) {
    throw Exception("User ID not found");
  }
  final response = await http.get(
    Uri.parse("${AuthAPIController.user_show}?id=$_user_id"),
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json",
      // Add token if needed
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return UserModel.fromJson(json['data']);
  } else {
    throw Exception("Failed to load user");
  }
});
