import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/%20business_logic/models/cart_model.dart';
import 'package:market_jango/core/constants/api_control/buyer_api.dart';

import '../../../../../core/utils/get_token_sharedpefarens.dart';
import '../model/cart_model.dart';

final List<CartItemModel> dummyCartItems = [
  CartItemModel(
    id: 1,
    imageUrl: 'https://picsum.photos/seed/picsum/200/300',
    name: 'Lorem ipsum dolor sit amet consectetur.',
    details: 'Pink, Size M',
    price: 17.00,
  ),
  CartItemModel(
    id: 2,
    imageUrl: 'https://picsum.photos/seed/picsum/200/300',
    name: 'Lorem ipsum dolor sit amet consectetur.',
    details: 'Pink, Size M',
    price: 17.00,
  ),
  CartItemModel(
    id: 3,
    imageUrl: 'https://picsum.photos/seed/picsum/200/300',
    name: 'Lorem ipsum dolor sit amet consectetur.',
    details: 'Pink, Size M',
    price: 17.00,
  ),
  CartItemModel(
    id: 4,
    imageUrl: 'https://picsum.photos/seed/picsum/200/300',
    name: 'Lorem ipsum dolor sit amet consectetur.',
    details: 'Pink, Size M',
    price: 17.00,
  ),
];

final cartProvider = FutureProvider<List<CartItem>>((ref) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null) throw Exception('Token not found');

  final url = Uri.parse(BuyerAPIController.cart); // Example: api/cart
  final response = await http.get(url, headers: {'token': token});

  if (response.statusCode == 200) {
    final body = jsonDecode(response.body);
    final data = body['data'] as List<dynamic>?;
    if (data == null) return [];
    return data
        .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Failed to load cart: ${response.statusCode}');
  }
});
