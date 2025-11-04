import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_user_type.dart';

import '../model/product_attribute_response_model.dart';

/// 🌐 API base URL
final String baseUrl = VendorAPIController.product_attribute_vendor;

final productAttributesProvider =
FutureProvider<ProductAttributeResponse>((ref) async {
  final url = Uri.parse(baseUrl);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  String ? token = prefs.getString("auth_token");
  if (token == null) throw Exception("Token not found");

  final response = await http.get(
    url,
    headers: {
      'token': token,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return ProductAttributeResponse.fromJson(data);
  } else {
    throw Exception('Failed to fetch product attributes');
  }
});