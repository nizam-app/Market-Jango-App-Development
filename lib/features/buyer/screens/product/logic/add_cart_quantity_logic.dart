// lib/core/api/cart_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

class CartService {
  static Future<Map<String, dynamic>> create({
    required int productId,
    required int quantity,
    required Map<String, String> attributes,
  }) async {
    final authStorage = AuthLocalStorage();
    final token = await authStorage.getToken();

    final uri = Uri.parse(BuyerAPIController.cart_create);

    // ✅ Use form-data format (MultipartRequest)
    final request = http.MultipartRequest('POST', uri);

    // Set headers
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token,
    });

    // ✅ Convert attributes to JSON format with arrays
    // Input: {"color":"red","size":"m"} 
    // Output: {"color":["red"],"size":["m"]}
    final Map<String, List<String>> attributesJson = {};
    attributes.forEach((key, value) {
      attributesJson[key] = [value];
    });

    // Convert to JSON string for form-data
    final attributesJsonString = jsonEncode(attributesJson);
    // Example: '{"color":["red"],"size":["m"]}'

    // Add form fields
    request.fields['product_id'] = productId.toString();
    request.fields['quantity'] = quantity.toString();
    request.fields['attributes'] = attributesJsonString;

    // Send request
    final streamedResponse = await request.send();
    final res = await http.Response.fromStream(streamedResponse);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Add to cart failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }
}
