// cart_service.dart
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

import '../model/cart_model.dart';

final cartServiceProvider = Provider<CartService>((ref) => CartService(ref));

enum CartAction { increase, decrease }

extension _CartActionApi on CartAction {
  String get api => this == CartAction.increase ? 'increase' : 'decrease';
}

class CartService {
  final Ref ref;
  CartService(this.ref);

  Future<void> deleteCartItem(int cartItemId) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    final uri = Uri.parse(BuyerAPIController.cartDelete(cartItemId));
    final res = await http.delete(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );

    if (res.statusCode == 404) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      throw Exception(map?['message']?.toString() ?? 'Cart item not found');
    }
    if (res.statusCode != 200) {
      final map = jsonDecode(res.body) as Map<String, dynamic>?;
      throw Exception(
        map?['message']?.toString() ?? 'Failed to remove: ${res.statusCode}',
      );
    }
  }

  /// API body: { "product_id": "<id>", "action": "increase|decrease" }
  Future<CartItem> updateQuantity({
    required int productId,
    required CartAction action,
  }) async {
    final token = await ref.read(authTokenProvider.future);
    if (token == null || token.isEmpty) {
      throw Exception('Token not found');
    }

    final uri = Uri.parse(BuyerAPIController.cart_create);
    final body = {'product_id': productId.toString(), 'action': action.api};

    final res = await http.post(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'token': token,
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to update cart: ${res.statusCode} ${res.reasonPhrase}',
      );
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return CartItem.fromJson(map['data'] ?? {});
  }
}
