import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:market_jango/core/constants/api_control/auth_api.dart';

final businessTypesProvider = FutureProvider<List<String>>((ref) async {
  final response = await http.get(Uri.parse(AuthAPIController.business_type));

  if (response.statusCode == 200) {
    final jsonBody = json.decode(response.body);

    if (jsonBody['status'] == 'success' && jsonBody['data'] is List) {
      return List<String>.from(jsonBody['data']);
    } else {
      throw Exception('Invalid data format');
    }
  } else {
    throw Exception('Failed to fetch business types');
  }
});
final selectedBusinessTypeProvider = StateProvider<String?>((ref) => null);
