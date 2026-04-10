import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/buyer/screens/refunds/model/buyer_track_path_model.dart';

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
  final msg = j['message']?.toString();
  if (msg != null && msg.isNotEmpty) return msg;
  return 'HTTP $code';
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

/// Live tracking — `GET /api/buyer/orders/{invoice_id}/track` (doc §C2).
class BuyerOrderTrackApi {
  BuyerOrderTrackApi._();
  static final BuyerOrderTrackApi instance = BuyerOrderTrackApi._();

  Future<Map<String, dynamic>> fetchLiveTrack(int invoiceId) async {
    final headers = await _buyerAuthHeaders();
    final uri = Uri.parse(BuyerAPIController.buyerOrderTrack(invoiceId));
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return Map<String, dynamic>.from(data);
  }

  /// `GET /api/buyer/orders/{invoice_id}/track/path` — pass [itemId] for the
  /// correct line when the invoice has multiple items (`doc/details.md` §10).
  Future<BuyerTrackPathData> fetchTrackPath(
    int invoiceId, {
    required int itemId,
  }) async {
    final headers = await _buyerAuthHeaders();
    final uri = Uri.parse(
      BuyerAPIController.buyerOrderTrackPath(
        invoiceId,
        itemId: itemId,
      ),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return BuyerTrackPathData.fromJson(Map<String, dynamic>.from(data));
  }
}
