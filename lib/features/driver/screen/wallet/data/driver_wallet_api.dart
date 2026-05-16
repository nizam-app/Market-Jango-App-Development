import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/features/driver/screen/wallet/model/driver_wallet_models.dart';

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

DriverOrdersPage<DriverWalletTransaction> _parseWalletTransactionsPage(
  Map<String, dynamic> data,
) {
  final nested = data['transactions'];
  if (nested is Map<String, dynamic>) {
    return DriverOrdersPage.parse(
      nested,
      DriverWalletTransaction.fromJson,
    );
  }
  if (data['data'] is List) {
    return DriverOrdersPage.parse(
      data,
      DriverWalletTransaction.fromJson,
    );
  }
  return const DriverOrdersPage(
    currentPage: 1,
    lastPage: 1,
    perPage: 20,
    total: 0,
    items: [],
  );
}

Future<Map<String, String>> _driverWalletHeaders() async {
  final token = await AuthLocalStorage().getToken();
  return {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (token != null && token.isNotEmpty) 'token': token,
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

class DriverWalletApi {
  DriverWalletApi._();
  static final DriverWalletApi instance = DriverWalletApi._();

  Future<DriverWalletOverview> fetchWallet() async {
    final headers = await _driverWalletHeaders();
    final uri = Uri.parse(DriverAPIController.driverWallet);
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top) ?? top;
    return DriverWalletOverview(Map<String, dynamic>.from(data));
  }

  Future<DriverOrdersPage<DriverWalletTransaction>> fetchTransactions({
    int page = 1,
    String? fromDate,
    String? toDate,
    String? type,
    String? status,
  }) async {
    final headers = await _driverWalletHeaders();
    final uri = Uri.parse(
      DriverAPIController.driverWalletTransactions(
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

  Future<DriverOrdersPage<DriverPayoutRequest>> fetchPayouts({
    int page = 1,
    String? status,
  }) async {
    final headers = await _driverWalletHeaders();
    final uri = Uri.parse(
      DriverAPIController.driverWalletPayouts(page: page, status: status),
    );
    final res = await http.get(uri, headers: headers);
    _throwIfBad(res);
    final top = _decodeObj(res.body);
    final data = _unwrapDataMap(top);
    return DriverOrdersPage.parse(data, DriverPayoutRequest.fromJson);
  }

  Future<void> requestPayout({
    required String amount,
    required String paymentMethod,
    required String account,
    required String accountHolderName,
    String? bankName,
    String? note,
  }) async {
    final headers = await _driverWalletHeaders();
    final uri = Uri.parse(DriverAPIController.driverWalletPayout);
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
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    _throwIfBad(res);
    _maybeAssertEnvelope(res.body);
  }
}
