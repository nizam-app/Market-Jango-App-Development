// vendor_pending_order_data.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/model/asign_to_order_driver_model.dart';


Future<List<VendorPendingOrder>> _fetchVendorPendingOrders(Ref ref) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null) {
    throw Exception('Token not found');
  }

  final url = VendorAPIController.vendor_order_driver; 
  final uri = Uri.parse(url);

  final res = await http.get(
    uri,
    headers: {
      'Accept': 'application/json',
      'token': token,
    },
  );

  if (res.statusCode != 200) {
    throw Exception('Failed to fetch pending orders: '
        '${res.statusCode} ${res.body}');
  }

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final response = VendorPendingOrderResponse.fromJson(map);
  return response.data.data;
}

/// Riverpod provider
final vendorPendingOrdersProvider =
FutureProvider<List<VendorPendingOrder>>((ref) async {
  return _fetchVendorPendingOrders(ref);
});