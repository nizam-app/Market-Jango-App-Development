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

    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token,
    };

    // ✅ Only attributes will be sent
    final body = jsonEncode({
      'product_id': productId,
      'quantity': quantity,
      'attributes':
          attributes, // example: {"color":"red","size":"m","brand":"apple"}
    });

    final res = await http.post(uri, headers: headers, body: body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Add to cart failed: ${res.statusCode} ${res.body}');
    }

    final decoded = jsonDecode(res.body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {'data': decoded};
  }
}
