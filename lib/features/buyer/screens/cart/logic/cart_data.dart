// lib/features/buyer/screens/cart/logic/cart_data.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../model/cart_model.dart'; // এখানে CartResponse/CartItem আছে ধরে নিলাম

final cartProvider = FutureProvider<CartResponse>((ref) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null || token.isEmpty) {
    throw Exception('Token not found');
  }

  final url = Uri.parse(BuyerAPIController.cart);
  final res = await http.get(
    url,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to load cart: ${res.statusCode} ${res.reasonPhrase}');
  }

  // পুরো response map দিয়ে CartResponse বানাও
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  return CartResponse.fromJson(json);
});