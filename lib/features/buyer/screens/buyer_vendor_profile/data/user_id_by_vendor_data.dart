// discord.gg/riva coded by rivator

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/auth_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';

final userIdByVendorIdProvider =
    FutureProvider.autoDispose.family<int?, int>((ref, vendorId) async {
  if (vendorId <= 0) return null;
  final token = await ref.watch(authTokenProvider.future);
  if (token == null || token.isEmpty) return null;
  final uri = Uri.parse('${AuthAPIController.vendor_show}?id=$vendorId');
  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );
  if (res.statusCode != 200) return null;
  final map = jsonDecode(res.body) as Map<String, dynamic>?;
  final data = map?['data'];
  if (data is! Map<String, dynamic>) return null;
  final uid = data['user_id'];
  if (uid != null) {
    if (uid is int && uid > 0) return uid;
    if (uid is num) return uid.toInt();
    final n = int.tryParse(uid.toString());
    if (n != null && n > 0) return n;
  }
  final vendor = data['vendor'];
  if (vendor is Map<String, dynamic>) {
    final vuid = vendor['user_id'];
    if (vuid != null) {
      if (vuid is int && vuid > 0) return vuid;
      if (vuid is num) return vuid.toInt();
      final n = int.tryParse(vuid.toString());
      if (n != null && n > 0) return n;
    }
  }
  return null;
});
