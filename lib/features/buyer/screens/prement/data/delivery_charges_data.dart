import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';

class DeliveryChargeItem {
  final int cartId;
  final int productId;
  final String productName;
  final int vendorId;
  final String vendorName;
  final int quantity;
  final String buyerZone;
  final String buyerTown;
  final String vendorTown;
  final int? routeId;
  final Map<String, num> chargesApplied;
  final num effectiveWeightKg;
  final num finalDeliveryCharge;

  const DeliveryChargeItem({
    required this.cartId,
    required this.productId,
    required this.productName,
    required this.vendorId,
    required this.vendorName,
    required this.quantity,
    required this.buyerZone,
    required this.buyerTown,
    required this.vendorTown,
    required this.routeId,
    required this.chargesApplied,
    required this.effectiveWeightKg,
    required this.finalDeliveryCharge,
  });

  factory DeliveryChargeItem.fromJson(Map<String, dynamic> json) {
    int asInt(dynamic v) => v is int ? v : int.tryParse('${v ?? ''}') ?? 0;
    num asNum(dynamic v) {
      if (v is num) return v;
      return num.tryParse('${v ?? ''}') ?? 0;
    }

    final rawCharges = json['charges_applied'];
    final charges = <String, num>{};
    if (rawCharges is Map<String, dynamic>) {
      rawCharges.forEach((k, v) {
        charges[k] = asNum(v);
      });
    }

    return DeliveryChargeItem(
      cartId: asInt(json['cart_id']),
      productId: asInt(json['product_id']),
      productName: (json['product_name'] ?? '').toString(),
      vendorId: asInt(json['vendor_id']),
      vendorName: (json['vendor_name'] ?? '').toString(),
      quantity: asInt(json['quantity']),
      buyerZone: (json['buyer_zone'] ?? '').toString(),
      buyerTown: (json['buyer_town'] ?? '').toString(),
      vendorTown: (json['vendor_town'] ?? '').toString(),
      routeId: json['route_id'] == null ? null : asInt(json['route_id']),
      chargesApplied: charges,
      effectiveWeightKg: asNum(json['effective_weight_kg']),
      finalDeliveryCharge: asNum(json['final_delivery_charge']),
    );
  }
}

class DeliveryChargesResponse {
  final List<DeliveryChargeItem> items;
  final num cartTotalDeliveryCharge;

  const DeliveryChargesResponse({
    required this.items,
    required this.cartTotalDeliveryCharge,
  });

  factory DeliveryChargesResponse.fromJson(Map<String, dynamic> json) {
    num asNum(dynamic v) {
      if (v is num) return v;
      return num.tryParse('${v ?? ''}') ?? 0;
    }

    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      return const DeliveryChargesResponse(items: [], cartTotalDeliveryCharge: 0);
    }
    final itemsRaw = data['items'];
    final items = (itemsRaw is List)
        ? itemsRaw
            .whereType<Map<String, dynamic>>()
            .map(DeliveryChargeItem.fromJson)
            .toList()
        : <DeliveryChargeItem>[];

    return DeliveryChargesResponse(
      items: items,
      cartTotalDeliveryCharge: asNum(data['cart_total_delivery_charge']),
    );
  }
}

final cartDeliveryChargesProvider =
    FutureProvider.autoDispose<DeliveryChargesResponse>((ref) async {
  final auth = AuthLocalStorage();
  final token = await auth.getToken();
  if (token == null || token.isEmpty) throw Exception('Not logged in');

  final res = await http.get(
    Uri.parse(BuyerAPIController.cartDeliveryCharges),
    headers: {'Accept': 'application/json', 'token': token},
  );

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  if (res.statusCode != 200) {
    final msg = map['message']?.toString() ?? 'Failed to load delivery charges';
    throw Exception(msg);
  }
  return DeliveryChargesResponse.fromJson(map);
});

