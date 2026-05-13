import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/buyer_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

List<String> _parseItemsList(dynamic body) {
  if (body is! Map<String, dynamic>) return [];
  final data = body['data'];
  if (data is Map<String, dynamic> && data['items'] is List) {
    return (data['items'] as List)
        .map((e) => e?.toString() ?? '')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty && e != 'null')
        .toList();
  }
  return [];
}

final visibilityZonesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) async {
    final token = await ref.watch(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');

    final uri = Uri.parse(BuyerAPIController.visibilityZones);
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );
    final map = jsonDecode(res.body);
    if (res.statusCode != 200) {
      final msg = (map is Map<String, dynamic>)
          ? (map['message']?.toString() ?? 'Failed to load zones')
          : 'Failed to load zones';
      throw Exception(msg);
    }
    return _parseItemsList(map);
  },
);

/// Towns for a delivery zone (`GET …/towns?zone_name=`).
final visibilityTownsByZoneProvider =
    FutureProvider.autoDispose.family<List<String>, String>(
  (ref, zone) async {
    final token = await ref.watch(authTokenProvider.future);
    if (token == null || token.isEmpty) throw Exception('Not logged in');
    if (zone.trim().isEmpty) return [];

    final uri = Uri.parse(
      BuyerAPIController.visibilityTownsByZone(zoneName: zone.trim()),
    );
    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json', 'token': token},
    );
    final map = jsonDecode(res.body);
    if (res.statusCode != 200) {
      final msg = (map is Map<String, dynamic>)
          ? (map['message']?.toString() ?? 'Failed to load towns')
          : 'Failed to load towns';
      throw Exception(msg);
    }
    return _parseItemsList(map);
  },
);

