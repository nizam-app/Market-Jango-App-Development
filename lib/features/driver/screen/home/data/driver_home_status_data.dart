// lib/features/driver/home/data/driver_home_stats_data.dart

import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/driver_api.dart';
import 'package:market_jango/core/utils/get_token_sharedpefarens.dart';
import 'package:market_jango/features/driver/screen/home/model/driver_home_status_model.dart';

Future<DriverHomeStats> _fetchDriverHomeStats(Ref ref) async {
  // token
  final token = await ref.read(authTokenProvider.future);
  if (token == null || token.isEmpty) {
    throw Exception('Auth token not found');
  }

  final url = DriverAPIController
      .driver_home_stats; // ← const e path: api/driver/home-stats
  final uri = Uri.parse(url);

  final res = await http.get(
    uri,
    headers: {'Accept': 'application/json', 'token': token},
  );

  if (res.statusCode != 200) {
    throw Exception(
      'Failed to fetch driver home stats: '
      '${res.statusCode} ${res.body}',
    );
  }

  final Map<String, dynamic> map = jsonDecode(res.body);
  final response = DriverHomeStatsResponse.fromJson(map);

  return response.data.data; // inner "data"
}

/// Riverpod provider
final driverHomeStatsProvider = FutureProvider<DriverHomeStats>((ref) async {
  return _fetchDriverHomeStats(ref);
});
