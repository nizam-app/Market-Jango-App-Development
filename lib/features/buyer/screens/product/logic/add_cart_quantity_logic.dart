// lib/core/api/cart_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartService {
  static Future<Map<String, dynamic>> create({
    required int productId,
    required String color,
    required String size,
    required int quantity,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    // যেটাতে সেভ করেছ সেটাই পড়বে—'auth_token' বা 'token'
    final token = prefs.getString('auth_token') ?? prefs.getString('token');

    final uri = Uri.parse(BuyerAPIController.cart_create);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'token': token, // ← তোমার API এটাই চায়
    };

    final body = jsonEncode({
      'product_id': productId,   // int হিসেবেই যাক
      'color': color,
      'size': size,
      'quantity': quantity,      // int
    });

    final res = await http.post(uri, headers: headers, body: body);

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Add to cart failed: ${res.statusCode} ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}