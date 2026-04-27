import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/vendor_api.dart';
import 'package:market_jango/core/utils/auth_header_provider.dart';
import 'package:market_jango/features/vendor/staff_management/model/vendor_moderator_model.dart';

List<VendorModerator> _decodeModeratorsList(String body) {
  final map = jsonDecode(body) as Map<String, dynamic>;
  final data = (map['data'] as List?) ?? const [];
  return data
      .whereType<Map>()
      .map((e) => VendorModerator.fromJson(e.cast<String, dynamic>()))
      .toList();
}

VendorModerator _decodeModerator(String body) {
  final map = jsonDecode(body) as Map<String, dynamic>;
  final data = (map['data'] as Map?)?.cast<String, dynamic>() ?? const {};
  return VendorModerator.fromJson(data);
}

Future<void> _throwIfFailed(http.Response res) async {
  if (res.statusCode >= 200 && res.statusCode < 300) return;
  throw Exception('Request failed: ${res.statusCode} ${res.body}');
}

final vendorModeratorsProvider =
    FutureProvider.autoDispose<List<VendorModerator>>((ref) async {
  final headers = await ref.watch(authHeadersProvider.future);
  final uri = Uri.parse(VendorAPIController.vendorModerators);
  final res = await http.get(uri, headers: headers);
  await _throwIfFailed(res);
  return _decodeModeratorsList(res.body);
});

final vendorModeratorProvider =
    FutureProvider.autoDispose.family<VendorModerator, int>((ref, id) async {
  final headers = await ref.watch(authHeadersProvider.future);
  final uri = Uri.parse(VendorAPIController.vendorModerator(id));
  final res = await http.get(uri, headers: headers);
  await _throwIfFailed(res);
  return _decodeModerator(res.body);
});

class VendorModeratorApi {
  static Future<VendorModerator> create({
    required Map<String, String> headers,
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final uri = Uri.parse(VendorAPIController.vendorModerators);
    final res = await http.post(
      uri,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    await _throwIfFailed(res);
    return _decodeModerator(res.body);
  }

  static Future<VendorModerator> update({
    required Map<String, String> headers,
    required int moderatorId,
    String? role,
    bool? isActive,
  }) async {
    final uri = Uri.parse(VendorAPIController.vendorModerator(moderatorId));
    final payload = <String, dynamic>{};
    if (role != null) payload['role'] = role;
    if (isActive != null) payload['is_active'] = isActive;
    final res = await http.put(uri, headers: headers, body: jsonEncode(payload));
    await _throwIfFailed(res);
    return _decodeModerator(res.body);
  }

  static Future<void> delete({
    required Map<String, String> headers,
    required int moderatorId,
  }) async {
    final uri = Uri.parse(VendorAPIController.vendorModerator(moderatorId));
    final res = await http.delete(uri, headers: headers);
    await _throwIfFailed(res);
  }
}

