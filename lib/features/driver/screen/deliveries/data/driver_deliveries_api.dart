import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/driver/screen/deliveries/model/driver_assignment_models.dart';

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

void _assertEnvelopeSuccess(Map<String, dynamic> top) {
  final st = top['status']?.toString().toLowerCase();
  if (st == 'error' || st == 'fail' || st == 'failed') {
    final msg = top['message']?.toString().trim();
    throw Exception(
      (msg != null && msg.isNotEmpty) ? msg : 'Request failed',
    );
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

Future<Map<String, String>> _headers() async {
  final storage = AuthLocalStorage();
  final token = await storage.getToken();
  final id = await storage.getUserId();
  final userType = await storage.getUserType();
  return {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'token': token,
    if (id != null && id.isNotEmpty) 'id': id,
    if (userType != null && userType.isNotEmpty) 'user_type': userType,
  };
}

/// `doc/details.md` — driver deliveries & lifecycle.
class DriverDeliveriesApi {
  DriverDeliveriesApi._();
  static final DriverDeliveriesApi instance = DriverDeliveriesApi._();

  Future<DriverAssignmentsPage> fetchDeliveries({
    int page = 1,
    String? status,
  }) async {
    final h = await _headers();
    final uri = Uri.parse(
      DriverAPIController.driverDeliveries(page: page, status: status),
    );
    final res = await http.get(uri, headers: h);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertEnvelopeSuccess(top);
    final data = _unwrapDataMap(top);
    return DriverAssignmentsPage.parse(data);
  }

  Future<DriverAssignmentRow> fetchDelivery(int id) async {
    final h = await _headers();
    final uri = Uri.parse(DriverAPIController.driverDelivery(id));
    final res = await http.get(uri, headers: h);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertEnvelopeSuccess(top);
    final data = _unwrapDataMap(top);
    if (data == null) {
      throw Exception('Invalid response: missing data');
    }
    return DriverAssignmentRow.fromJson(data);
  }

  Future<DriverAssignmentRow> accept(int id) => _postAssignment(id, 'accept');

  Future<DriverAssignmentRow> reject(int id, {required String reason}) async {
    final h = await _headers();
    final uri = Uri.parse(DriverAPIController.driverDeliveryReject(id));
    final res = await http.post(
      uri,
      headers: h,
      body: jsonEncode({'reason': reason.trim()}),
    );
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertEnvelopeSuccess(top);
    final data = _unwrapDataMap(top);
    if (data == null) throw Exception('Invalid response');
    return DriverAssignmentRow.fromJson(data);
  }

  Future<DriverAssignmentRow> pickup(int id) => _postAssignment(id, 'pickup');

  Future<DriverAssignmentRow> deliver(int id) => _postAssignment(id, 'deliver');

  Future<DriverAssignmentRow> _postAssignment(int id, String action) async {
    final h = await _headers();
    final String url = switch (action) {
      'accept' => DriverAPIController.driverDeliveryAccept(id),
      'pickup' => DriverAPIController.driverDeliveryPickup(id),
      'deliver' => DriverAPIController.driverDeliveryDeliver(id),
      _ => throw ArgumentError(action),
    };
    final uri = Uri.parse(url);
    final res = await http.post(uri, headers: h, body: jsonEncode({}));
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertEnvelopeSuccess(top);
    final data = _unwrapDataMap(top);
    if (data == null) throw Exception('Invalid response');
    return DriverAssignmentRow.fromJson(data);
  }

  /// Returns server `data` map (latitude, longitude, recorded_at, …).
  Future<Map<String, dynamic>> postLocation(
    int id, {
    required double latitude,
    required double longitude,
    double? heading,
    double? speed,
  }) async {
    final h = await _headers();
    final uri = Uri.parse(DriverAPIController.driverDeliveryLocation(id));
    final body = <String, dynamic>{
      'latitude': latitude,
      'longitude': longitude,
      if (heading != null) 'heading': heading,
      if (speed != null) 'speed': speed,
    };
    final res = await http.post(
      uri,
      headers: h,
      body: jsonEncode(body),
    );
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    _assertEnvelopeSuccess(top);
    final data = _unwrapDataMap(top);
    return data ?? {};
  }
}
