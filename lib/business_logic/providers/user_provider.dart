import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';

// Simple API call
Future<UserApiResponse> fetchUserData() async {
  final response = await http.post(
    Uri.parse('http://103.208.183.253:8000/api/user/show'),
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'id': "1"}),
  );

  if (response.statusCode == 200) {
    return UserApiResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Failed to load user data: ${response.statusCode}');
  }
}

// Simple provider
final userProvider = FutureProvider<UserModel>((ref) async {
  final response = await fetchUserData();
  return response.data;
});
