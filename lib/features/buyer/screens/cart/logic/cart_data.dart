import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../model/cart_model.dart';

final cartProvider = FutureProvider<List<CartItem>>((ref) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null || token.isEmpty) throw Exception('Token not found');

  final url = Uri.parse(BuyerAPIController.cart); // e.g. /api/cart
  final response = await http.get(
    url,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Failed to load cart: ${response.statusCode} ${response.reasonPhrase}',
    );
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  final parsed = CartResponse.fromJson(body);

  // চাইলে সরাসরি parsed.items ফেরত দাও:
  return parsed.items;
});
