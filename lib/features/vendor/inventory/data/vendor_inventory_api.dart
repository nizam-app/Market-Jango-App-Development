import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/auth_header_provider.dart';
import 'package:market_jango/features/vendor/inventory/model/vendor_inventory_model.dart';

Future<void> _throwIfFailed(http.Response res) async {
  if (res.statusCode >= 200 && res.statusCode < 300) return;
  throw Exception('Request failed: ${res.statusCode} ${res.body}');
}

final vendorInventorySearchProvider = StateProvider<String>((ref) => '');

final vendorInventoryProvider = FutureProvider.autoDispose<List<VendorInventoryProduct>>((ref) async {
  final headers = await ref.watch(authHeadersProvider.future);
  final search = ref.watch(vendorInventorySearchProvider).trim();
  final uri = Uri.parse(VendorAPIController.vendorInventory(search: search));
  final res = await http.get(uri, headers: headers);
  await _throwIfFailed(res);

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  final list = (data['data'] as List?) ?? const [];
  return list
      .whereType<Map>()
      .map((e) => VendorInventoryProduct.fromJson(e.cast<String, dynamic>()))
      .toList();
});

final vendorInventoryLogsProvider = FutureProvider.autoDispose.family<VendorInventoryProductLogsResponse, int>((ref, productId) async {
  final headers = await ref.watch(authHeadersProvider.future);
  final uri = Uri.parse(VendorAPIController.vendorInventoryProduct(productId));
  final res = await http.get(uri, headers: headers);
  await _throwIfFailed(res);

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  final productJson = (data['product'] as Map?)?.cast<String, dynamic>() ?? const {};
  final logsPaginated = (data['logs'] as Map?)?.cast<String, dynamic>() ?? const {};
  final logsList = (logsPaginated['data'] as List?) ?? const [];

  return VendorInventoryProductLogsResponse(
    product: VendorInventoryProduct.fromJson(productJson),
    logs: logsList
        .whereType<Map>()
        .map((e) => VendorInventoryLog.fromJson(e.cast<String, dynamic>()))
        .toList(),
  );
});

final vendorInventorySummaryProvider = FutureProvider.autoDispose.family<List<VendorInventorySummaryEvent>, int>((ref, productId) async {
  final headers = await ref.watch(authHeadersProvider.future);
  final uri = Uri.parse(VendorAPIController.vendorInventorySummary(productId));
  final res = await http.get(uri, headers: headers);
  await _throwIfFailed(res);

  final map = jsonDecode(res.body) as Map<String, dynamic>;
  final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  final events = (data['events'] as List?) ?? const [];
  return events
      .whereType<Map>()
      .map((e) => VendorInventorySummaryEvent.fromJson(e.cast<String, dynamic>()))
      .toList();
});

