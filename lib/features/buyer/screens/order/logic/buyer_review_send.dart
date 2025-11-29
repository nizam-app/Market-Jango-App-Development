import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<String> submitReviewToApi({
  required String url,
  required double rating,
  required String comment,
}) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final res = await http.post(
    Uri.parse(url),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'token': token,
    },
    body: jsonEncode({'review': comment.trim(), 'rating': rating.toInt()}),
  );

  Map<String, dynamic> bodyJson = {};
  try {
    bodyJson = jsonDecode(res.body) as Map<String, dynamic>;
  } catch (_) {}

  final msg =
      bodyJson['message']?.toString() ?? 'Review submitted successfully';

  if (res.statusCode < 200 || res.statusCode >= 300) {
    throw Exception(msg);
  }

  return msg; // success message or "You already rated this item"
}
