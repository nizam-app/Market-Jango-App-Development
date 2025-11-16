// vendor_product_delete_logic.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_user_type.dart';

/// product delete API
/// POST {{baseurl}}api/product/destroy/{id}
Future<bool> deleteVendorProduct({
  required WidgetRef ref,
  required int productId,
}) async {
  final prefs = await ref.read(sharedPreferencesProvider.future);
  final token = prefs.getString('auth_token');
  if (token == null) {
    throw Exception('Token not found');
  }

 
  final url = Uri.parse(
    "${VendorAPIController.product_destroy}/$productId",
  ); 

  final res = await http.post(
    url,
    headers: {
      'Accept': 'application/json',
      'token': token,
    },
  );

  if (res.statusCode != 200) {
    throw Exception('Delete failed: ${res.statusCode}');
  }

  final body = jsonDecode(res.body);
  if (body['status'] == 'success') {
    return true;
  }
  throw Exception(body['message'] ?? 'Delete failed');
}