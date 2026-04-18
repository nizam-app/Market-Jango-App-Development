import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/model/vendor_orders_models.dart';
import 'package:market_jango/features/vendor/screens/vendor_order_management/vendor_order_auth.dart';

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

VendorMarketplaceLineDetail _marketplaceDetailFromTop(Map<String, dynamic> top) {
  Map<String, dynamic> data = _unwrapDataMap(top) ?? top;
  final parentLineItems = data['line_items'];
  // Parent `order` / `order_status` often sit next to `invoice_item`, not inside it.
  // Assign-driver validates parent order state — keep these on the line map we parse.
  final parentOrder = data['order'];
  final parentOrderStatus = data['order_status'];
  final nested = data['invoice_item'] ?? data['item'] ?? data['data'];
  if (nested is Map<String, dynamic>) {
    final merged = Map<String, dynamic>.from(nested);
    if (merged['order'] == null && parentOrder != null) {
      merged['order'] = parentOrder;
    }
    if (merged['order_status'] == null &&
        parentOrderStatus != null &&
        parentOrderStatus.toString().trim().isNotEmpty) {
      merged['order_status'] = parentOrderStatus;
    }
    data = merged;
  }
  if (parentLineItems is List && data['line_items'] is! List) {
    data = Map<String, dynamic>.from(data)..['line_items'] = parentLineItems;
  }
  return VendorMarketplaceLineDetail.fromJson(data);
}

String _formatApiError(Map<String, dynamic> j, int code) {
  final parts = <String>[];
  final msg = j['message']?.toString();
  if (msg != null && msg.isNotEmpty) parts.add(msg);
  final errors = j['errors'];
  if (errors is Map) {
    for (final e in errors.entries) {
      final k = e.key.toString();
      final v = e.value;
      if (v is List) {
        for (final item in v) {
          parts.add('• $k: $item');
        }
      } else {
        parts.add('• $k: $v');
      }
    }
  }
  if (parts.isEmpty) return 'HTTP $code';
  return parts.join('\n');
}

/// Laravel body with HTTP 200 but `status: error` (e.g. insufficient balance).
String _formatBusinessError(Map<String, dynamic> top) {
  final msg = top['message']?.toString().trim();
  final base = (msg != null && msg.isNotEmpty) ? msg : 'Request failed';
  final data = top['data'];
  if (data is Map<String, dynamic>) {
    final bal = data['balance'];
    final req = data['requested'];
    if (bal != null || req != null) {
      return '$base\nAvailable: $bal · Requested: $req';
    }
  }
  return base;
}

void _assertJsonSuccess(Map<String, dynamic> top) {
  final st = top['status']?.toString().toLowerCase();
  if (st == 'error' || st == 'fail' || st == 'failed') {
    throw Exception(_formatBusinessError(top));
  }
}

/// Wallet tx list: `data.transactions` paginator (doc) or legacy flat `data`.
VendorOrdersPage<VendorWalletTransaction> _parseWalletTransactionsPage(
  Map<String, dynamic> data,
) {
  final nested = data['transactions'];
  if (nested is Map<String, dynamic>) {
    return VendorOrdersPage.parse(nested, VendorWalletTransaction.fromJson);
  }
  if (data['data'] is List) {
    return VendorOrdersPage.parse(data, VendorWalletTransaction.fromJson);
  }
  return const VendorOrdersPage(
    currentPage: 1,
    lastPage: 1,
    perPage: 20,
    total: 0,
    items: [],
  );
}

void _throwIfBad(http.Response res) {
  if (res.statusCode >= 200 && res.statusCode < 300) return;
  try {
    final j = _decodeObj(res.body);
    throw Exception(_formatApiError(j, res.statusCode));
  } catch (e) {
    if (e is Exception &&
        e.toString().startsWith('Exception:') &&
        !e.toString().contains('Invalid JSON')) {
      rethrow;
    }
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
    return VendorOrdersPage.parse(data, VendorMarketplaceLine.fromJson);
  }

  Future<VendorMarketplaceLineDetail> fetchMarketplaceLineDetail(int id) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorOrderDetail(id));
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    return _marketplaceDetailFromTop(top);
  }

  /// `GET /vendor/drivers/available` — optional `search` on driver user name.
  Future<List<VendorAvailableDriver>> fetchAvailableDrivers({
    String? search,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorDriversAvailable(search: search),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertJsonSuccess(top);
    final d = top['data'];
    final rows = <Map<String, dynamic>>[];
    if (d is List) {
      for (final e in d) {
        if (e is Map<String, dynamic>) rows.add(e);
      }
    } else if (d is Map<String, dynamic>) {
      final inner = d['data'] ?? d['drivers'];
      if (inner is List) {
        for (final e in inner) {
          if (e is Map<String, dynamic>) rows.add(e);
        }
      }
    }
    return rows.map(VendorAvailableDriver.fromJson).toList();
  }

  /// `GET /vendor/orders/{item_id}/assignment` — `order_item` + `assignments`.
  Future<VendorOrderAssignmentPayload> fetchOrderAssignmentHistory(
    int invoiceItemId,
  ) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorOrderAssignment(invoiceItemId),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertJsonSuccess(top);
    final data = _unwrapDataMap(top) ?? top;
    return VendorOrderAssignmentPayload.fromJson(data);
  }

  /// `POST /vendor/orders/{item_id}/assign-driver` — body `driver_id`.
  Future<void> assignDriverToOrderItem({
    required int invoiceItemId,
    required int driverId,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorOrderAssignDriver(invoiceItemId),
    );
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{'driver_id': driverId}),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }

  /// `POST /vendor/orders/{item_id}/unassign-driver` — cancels latest active assignment.
  Future<void> unassignDriverFromOrderItem(int invoiceItemId) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorOrderUnassignDriver(invoiceItemId),
    );
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{}),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
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
    final res = await http.put(uri, headers: headers, body: jsonEncode(body));
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    return _marketplaceDetailFromTop(top);
  }

  /// `POST /vendor/orders/{id}/cancel` — body `{ "reason": "..." }`.
  Future<void> cancelMarketplaceLine({
    required int invoiceItemId,
    required String reason,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorOrderCancel(invoiceItemId));
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{'reason': reason}),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }

  /// `PATCH /vendor/orders/{id}/quantity` — body `{ "quantity": n, "reason": "..." }`.
  Future<void> patchMarketplaceLineQuantity({
    required int invoiceItemId,
    required int quantity,
    required String reason,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorOrderQuantity(invoiceItemId),
    );
    final res = await http.patch(
      uri,
      headers: headers,
      body: jsonEncode(<String, dynamic>{
        'quantity': quantity,
        'reason': reason,
      }),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
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
    return VendorOrdersPage.parse(data, VendorManualOrderInvoice.fromJson);
  }

  Future<VendorManualOrderInvoice> fetchManualOrderDetail(int invoiceId) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorManualOrderDetail(invoiceId),
    );
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

  /// `POST /api/vendor/manual-orders` — body per doc: `customer_name` (max 100),
  /// optional `customer_phone` (max 30), `payment_method` ∈ `Cash`|`Card`|`Mobile`,
  /// optional `customer_paid` (≥ 0), `items` (min 1).
  Future<VendorManualOrderInvoice> createManualOrder({
    required String customerName,
    String? customerPhone,
    required String paymentMethod,
    double? customerPaid,
    required List<Map<String, int>> items,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorManualOrderCreate);
    var nameTrim = customerName.trim();
    if (nameTrim.length > 100) {
      nameTrim = nameTrim.substring(0, 100);
    }
    final body = <String, dynamic>{
      'customer_name': nameTrim,
      'payment_method': paymentMethod,
      'items': items
          .map(
            (e) => {'product_id': e['product_id'], 'quantity': e['quantity']},
          )
          .toList(),
    };
    final phoneTrim = customerPhone?.trim();
    if (phoneTrim != null && phoneTrim.isNotEmpty) {
      body['customer_phone'] = phoneTrim.length > 30
          ? phoneTrim.substring(0, 30)
          : phoneTrim;
    }
    if (customerPaid != null) {
      body['customer_paid'] = customerPaid;
    }
    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertJsonSuccess(top);
    final data = _unwrapDataMap(top) ?? top;
    // Response may nest invoice/items/summary (201 Created + `data.invoice` per API).
    if (data.containsKey('invoice') &&
        data['invoice'] is Map<String, dynamic>) {
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
    final uri = Uri.parse(
      VendorAPIController.vendorManualOrderAddItem(invoiceId),
    );
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    if (data.containsKey('invoice') &&
        data['invoice'] is Map<String, dynamic>) {
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
    if (data.containsKey('invoice') &&
        data['invoice'] is Map<String, dynamic>) {
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
    final uri = Uri.parse(
      VendorAPIController.vendorManualOrderDeliver(invoiceId),
    );
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
    if (data.containsKey('invoice') &&
        data['invoice'] is Map<String, dynamic>) {
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
    String? type,
    String? status,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorWalletTransactions(
        page: page,
        fromDate: fromDate,
        toDate: toDate,
        type: type,
        status: status,
      ),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return _parseWalletTransactionsPage(Map<String, dynamic>.from(data));
  }

  /// `GET /vendor/wallet/payouts`
  Future<VendorOrdersPage<VendorPayoutRequest>> fetchWalletPayouts({
    int page = 1,
    String? status,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorWalletPayouts(page: page, status: status),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top);
    return VendorOrdersPage.parse(data, VendorPayoutRequest.fromJson);
  }

  /// `GET /vendor/refunds`
  Future<VendorRefundsPayload> fetchRefunds({
    int page = 1,
    String? status,
    String? fromDate,
    String? toDate,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorRefunds(
        page: page,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top);
    return VendorRefundsPayload.parse(data);
  }

  /// `GET /vendor/refunds/{id}`
  Future<VendorRefundDetail> fetchRefundDetail(int id) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorRefundDetail(id));
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return VendorRefundDetail.fromJson(Map<String, dynamic>.from(data));
  }

  /// `POST /vendor/refunds/{id}/approve`
  Future<void> approveRefund(int id, {String? note}) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorRefundApprove(id));
    final body = <String, dynamic>{};
    final n = note?.trim();
    if (n != null && n.isNotEmpty) body['note'] = n;
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body.isEmpty ? <String, dynamic>{} : body),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }

  /// `POST /vendor/refunds/{id}/reject` — `note` required by API.
  Future<void> rejectRefund(int id, {required String note}) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorRefundReject(id));
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({'note': note.trim()}),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }

  /// `POST /vendor/orders/{item_id}/refund`
  Future<void> requestMarketplaceLineRefund({
    required int invoiceItemId,
    required String reason,
    double? amount,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(
      VendorAPIController.vendorOrderLineRefund(invoiceItemId),
    );
    final body = <String, dynamic>{'reason': reason.trim()};
    if (amount != null) body['amount'] = amount;
    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }

  void _maybeAssertEnvelope(String body) {
    final raw = body.trim();
    if (raw.isEmpty) return;
    Map<String, dynamic>? top;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) top = decoded;
    } on FormatException {
      return;
    }
    if (top != null) _assertJsonSuccess(top);
  }

  /// `POST /vendor/wallet/payout` — see doc/FLUTTER_API_BY_ROLE.md §2.3
  ///
  /// Backend expects `payment_details` as a map with at least `account` and `name`.
  Future<void> requestWalletPayout({
    required String amount,
    required String paymentMethod,
    required String account,
    required String accountHolderName,
    String? bankName,
    String? note,
  }) async {
    final headers = await vendorOrderApiHeaders();
    final uri = Uri.parse(VendorAPIController.vendorWalletPayout);
    final amountTrim = amount.trim();
    final parsed = num.tryParse(amountTrim);
    final details = <String, dynamic>{
      'account': account.trim(),
      'name': accountHolderName.trim(),
    };
    final bank = bankName?.trim();
    if (bank != null && bank.isNotEmpty) {
      details['bank_name'] = bank;
    }
    final body = <String, dynamic>{
      'amount': parsed ?? amountTrim,
      'payment_method': paymentMethod.trim(),
      'payment_details': details,
    };
    final n = note?.trim();
    if (n != null && n.isNotEmpty) body['note'] = n;
    final res = await http.post(uri, headers: headers, body: jsonEncode(body));
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }
}
