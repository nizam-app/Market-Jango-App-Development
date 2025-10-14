import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> postfrem({required String keyname, required String name, required String url}) async {
  final sp = await SharedPreferences.getInstance();
  final token = sp.getString('auth_token'); // already "Bearer xxx"
  if (token == null || token.isEmpty) throw 'Missing auth token';

  final res = await http.post(
    Uri.parse(url),
    headers: {
      'Content-Type': 'application/json',
      'token': token, // e.g., "Bearer eyJ..."
    },
    body: jsonEncode({keyname: name}),
  );
  Logger().d(res.body);

  if (res.statusCode < 200 || res.statusCode >= 300) return false;

  // optional: if your API returns { status: "success" }
  final j = jsonDecode(res.body);
  return (j is Map && (j['status'] ?? '').toString().toLowerCase() =='success');
}
