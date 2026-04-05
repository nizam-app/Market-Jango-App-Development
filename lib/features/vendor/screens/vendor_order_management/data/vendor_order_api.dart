import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/vendor_order_auth.dart';

String _msg(Map<String, dynamic> j) =>
    j['message']?.toString() ?? 'Request failed';

Map<String, dynamic> _decodeObj(String body) {
  final decoded = jsonDecode(body);
  if (decoded is Map<String, dynamic>) return decoded;
  throw Exception('Invalid JSON');
}

Map<String, dynamic>? _unwrapDataMap(Map<String, dynamic> top) {
  final d = top['data'];
  if (d is Map<String, dynamic>) return d;
  return null;
}

void _throwIfBad(http.Response res) {
  if (res.statusCode >= 200 && res.statusCode < 300) return;
  try {
    final j = _decodeObj(res.body);
    throw Exception(_msg(j));
  } catch (_) {
    throw Exception('HTTP ${res.statusCode}');
  }
}

class VendorOrderApi {
  VendorOrderApi._();
  static final VendorOrderApi instance = VendorOrderApi._();

  Future<VendorOrdersPage<VendorMarketplaceLine>> fetchMarketplaceOrders({
    int page = 1,
    int perPage = 10,
    String? fromDate,
    String? toDate,
    String? orderNumber,
    String? status,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorOrders(
        page: page,
        perPage: perPage,
        fromDate: fromDate,
        toDate: toDate,
        orderNumber: orderNumber,
        status: status,
      ),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top);
    return VendorOrdersPage.parse(
      data,
      VendorMarketplaceLine.fromJson,
    );
  }

  Future<VendorMarketplaceLineDetail> fetchMarketplaceLineDetail(int id) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorOrderDetail(id));
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    Map<String, dynamic> data = _unwrapDataMap(top) ?? top;
    final nested = data['invoice_item'] ?? data['item'] ?? data['data'];
    if (nested is Map<String, dynamic>) {
      data = nested;
    }
    return VendorMarketplaceLineDetail.fromJson(data);
  }

  Future<VendorMarketplaceLineDetail> updateMarketplaceLineStatus({
    required int id,
    required String status,
    String? note,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorOrderUpdateStatus(id));
    final body = <String, dynamic>{'status': status};
    if (note != null && note.isNotEmpty) body['note'] = note;
    final res = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    Map<String, dynamic> data = _unwrapDataMap(top) ?? top;
    final nested = data['invoice_item'] ?? data['item'] ?? data['data'];
    if (nested is Map<String, dynamic>) {
      data = nested;
    }
    return VendorMarketplaceLineDetail.fromJson(data);
  }

  Future<VendorOrderStatusesPayload> fetchOrderStatuses() async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorOrderStatuses);
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return VendorOrderStatusesPayload.fromJson(data);
  }

  Future<VendorOrdersPage<VendorManualOrderInvoice>> fetchManualOrders({
    int page = 1,
    int perPage = 10,
    String? fromDate,
    String? toDate,
    String? orderNumber,
    String? status,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorManualOrders(
        page: page,
        perPage: perPage,
        fromDate: fromDate,
        toDate: toDate,
        orderNumber: orderNumber,
        status: status,
      ),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top);
    return VendorOrdersPage.parse(
      data,
      VendorManualOrderInvoice.fromJson,
    );
  }

  Future<VendorManualOrderInvoice> fetchManualOrderDetail(int invoiceId) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorManualOrderDetail(invoiceId));
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    Map<String, dynamic> data = _unwrapDataMap(top) ?? top;
    final nested = data['invoice'] ?? data['data'];
    if (nested is Map<String, dynamic> &&
        (nested.containsKey('order_number') || nested.containsKey('items'))) {
      final merged = Map<String, dynamic>.from(nested);
      if (data['items'] is List) merged['items'] = data['items'];
      if (data['summary'] is Map) merged['summary'] = data['summary'];
      data = merged;
    }
    return VendorManualOrderInvoice.fromJson(data);
  }

  Future<VendorManualOrderInvoice> createManualOrder({
    required String customerName,
    String? customerPhone,
    required String paymentMethod,
    double? customerPaid,
    required List<Map<String, int>> items,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorManualOrderCreate);
    final body = <String, dynamic>{
      'customer_name': customerName,
      'payment_method': paymentMethod,
      'items': items
          .map((e) => {'product_id': e['product_id'], 'quantity': e['quantity']})
          .toList(),
    };
    if (customerPhone != null && customerPhone.isNotEmpty) {
      body['customer_phone'] = customerPhone;
    }
    if (customerPaid != null) body['customer_paid'] = customerPaid;
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    // Response may nest invoice/items/summary
    if (data.containsKey('invoice') && data['invoice'] is Map<String, dynamic>) {
      final inv = Map<String, dynamic>.from(
        data['invoice'] as Map<String, dynamic>,
      );
      if (data['items'] is List) inv['items'] = data['items'];
      if (data['summary'] is Map) inv['summary'] = data['summary'];
      return VendorManualOrderInvoice.fromJson(inv);
    }
    return VendorManualOrderInvoice.fromJson(data);
  }

  Future<VendorManualOrderInvoice> addManualOrderItem({
    required int invoiceId,
    required int productId,
    required int quantity,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorManualOrderAddItem(invoiceId));
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    if (data.containsKey('invoice') && data['invoice'] is Map<String, dynamic>) {
      final inv = Map<String, dynamic>.from(
        data['invoice'] as Map<String, dynamic>,
      );
      if (data['items'] is List) inv['items'] = data['items'];
      if (data['summary'] is Map) inv['summary'] = data['summary'];
      return VendorManualOrderInvoice.fromJson(inv);
    }
    return VendorManualOrderInvoice.fromJson(data);
  }

  Future<VendorManualOrderInvoice> deleteManualOrderItem({
    required int invoiceId,
    required int itemId,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorManualOrderDeleteItem(invoiceId, itemId),
    );
    final res = await http.delete(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    if (data.containsKey('invoice') && data['invoice'] is Map<String, dynamic>) {
      final inv = Map<String, dynamic>.from(
        data['invoice'] as Map<String, dynamic>,
      );
      if (data['items'] is List) inv['items'] = data['items'];
      if (data['summary'] is Map) inv['summary'] = data['summary'];
      return VendorManualOrderInvoice.fromJson(inv);
    }
    return VendorManualOrderInvoice.fromJson(data);
  }

  Future<VendorManualOrderInvoice> deliverManualOrder({
    required int invoiceId,
    double? customerPaid,
    String? note,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorManualOrderDeliver(invoiceId));
    final body = <String, dynamic>{};
    if (customerPaid != null) body['customer_paid'] = customerPaid;
    if (note != null && note.isNotEmpty) body['note'] = note;
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body.isEmpty ? <String, dynamic>{} : body),
    );
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    if (data.containsKey('invoice') && data['invoice'] is Map<String, dynamic>) {
      final inv = Map<String, dynamic>.from(
        data['invoice'] as Map<String, dynamic>,
      );
      if (data['items'] is List) inv['items'] = data['items'];
      if (data['summary'] is Map) inv['summary'] = data['summary'];
      return VendorManualOrderInvoice.fromJson(inv);
    }
    return VendorManualOrderInvoice.fromJson(data);
  }

  Future<VendorWalletOverview> fetchWallet() async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorWallet);
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return VendorWalletOverview(Map<String, dynamic>.from(data));
  }

  Future<VendorOrdersPage<VendorWalletTransaction>> fetchWalletTransactions({
    int page = 1,
    String? fromDate,
    String? toDate,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorWalletTransactions(
        page: page,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top);
    return VendorOrdersPage.parse(
      data,
      VendorWalletTransaction.fromJson,
    );
  }
}
