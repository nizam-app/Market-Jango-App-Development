import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../model/profile_model.dart';

final userProvider = FutureProvider<UserModel>((ref) async {
  final response = await http.get(
    Uri.parse("https://yourapi.com/api/user/show"),
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
