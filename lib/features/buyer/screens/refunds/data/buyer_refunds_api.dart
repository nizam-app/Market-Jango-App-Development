import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/screens/refunds/model/buyer_refund_models.dart';

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

String _formatBusinessError(Map<String, dynamic> top) {
  final msg = top['message']?.toString().trim();
  return (msg != null && msg.isNotEmpty) ? msg : 'Request failed';
}

void _assertJsonSuccess(Map<String, dynamic> top) {
  final st = top['status']?.toString().toLowerCase();
  if (st == 'error' || st == 'fail' || st == 'failed') {
    throw Exception(_formatBusinessError(top));
  }
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

Future<Map<String, String>> _buyerAuthHeaders() async {
  final storage = AuthLocalStorage();
  final token = await storage.getToken();
  final id = await storage.getUserId();
  final userType = await storage.getUserType();
  final userJson = await storage.getUserJson();
  final email = userJson?['email']?.toString();
  return {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'token': token,
    if (id != null && id.isNotEmpty) 'id': id,
    if (userType != null && userType.isNotEmpty) 'user_type': userType,
    if (email != null && email.isNotEmpty) 'email': email,
  };
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

class BuyerRefundsApi {
  BuyerRefundsApi._();
  static final BuyerRefundsApi instance = BuyerRefundsApi._();

  Future<BuyerRefundsPayload> fetchRefunds({
    int page = 1,
    String? status,
  }) async {
    final headers = await _buyerAuthHeaders();
    final uri = Uri.parse(
      BuyerAPIController.buyerRefunds(page: page, status: status),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return BuyerRefundsPayload.parse(Map<String, dynamic>.from(data));
  }

  Future<BuyerRefundDetail> fetchRefundDetail(int id) async {
    final headers = await _buyerAuthHeaders();
    final uri = Uri.parse(BuyerAPIController.buyerRefundDetail(id));
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return BuyerRefundDetail.fromJson(Map<String, dynamic>.from(data));
  }

  /// `POST /api/buyer/orders/{invoice_item_id}/refund`
  Future<void> requestLineRefund({
    required int invoiceItemId,
    required String reason,
    double? amount,
  }) async {
    final headers = await _buyerAuthHeaders();
    final uri = Uri.parse(
      BuyerAPIController.buyerOrderLineRefund(invoiceItemId),
    );
    final body = <String, dynamic>{'reason': reason.trim()};
    if (amount != null) body['amount'] = amount;
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }
}
