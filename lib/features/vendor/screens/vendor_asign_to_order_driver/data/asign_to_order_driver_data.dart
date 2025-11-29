// vendor_pending_order_data.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/vendor/screens/vendor_asign_to_order_driver/model/asign_to_order_driver_model.dart';

/// 🔹 current page রাখার provider
final vendorPendingCurrentPageProvider = StateProvider<int>((ref) => 1);

/// 🔹 API call with page
Future<VendorPendingOrderPage> _fetchVendorPendingOrders(
  Ref ref,
  int page,
) async {
  final token = await ref.read(authTokenProvider.future);
  if (token == null) {
    throw Exception('Token not found');
  }

  final baseUrl =
      VendorAPIController.vendor_order_driver; // e.g. /vendor/all/order
  final uri = Uri.parse('$baseUrl?page=$page');

  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (res.statusCode != 200) {
    throw Exception(
      'Failed to fetch pending orders: ${res.statusCode} ${res.body}',
    );
  }

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final response = VendorPendingOrderResponse.fromJson(map);
  return response.data; // এতে current_page, last_page + data সবই আছে
}

/// 🔹 Riverpod pagination provider
final vendorPendingOrdersProvider =
    FutureProvider.autoDispose<VendorPendingOrderPage>((ref) async {
      final page = ref.watch(vendorPendingCurrentPageProvider);
      return _fetchVendorPendingOrders(ref, page);
    });
