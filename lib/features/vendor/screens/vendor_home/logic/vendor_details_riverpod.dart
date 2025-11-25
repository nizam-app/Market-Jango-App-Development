import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/user_details_model.dart';

final vendorProvider = FutureProvider<VendorDetailsModel>((ref) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  String? _user_token = _sharedPreferences.getString("auth_token");
  if (_user_token == null) {
    throw Exception("User ID not found");
  }
  final response = await http.get(
    Uri.parse(AuthAPIController.vendor_show),
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "token": _user_token, // Replace or inject token dynamically
    },
  );

  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    return VendorDetailsModel.fromJson(json['data']);
  } else {
    throw Exception("Failed to load vendor data");
  }
});
