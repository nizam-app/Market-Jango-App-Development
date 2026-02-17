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

  // Parse response body to check for errors even if status code is 200
  Map<String, dynamic>? responseMap;
  try {
    responseMap = jsonDecode(res.body) as Map<String, dynamic>?;
  } catch (e) {
    throw Exception(
      'Failed to parse driver home stats response: $e. '
      'Status: ${res.statusCode}, Body: ${res.body}',
    );
  }

  // Check if response indicates failure (even with 200 status code)
  if (responseMap != null && responseMap['status'] == 'failed') {
    final errorMessage = responseMap['message']?.toString() ?? 
                        responseMap['data']?.toString() ?? 
                        'Something went wrong';
    throw Exception(
      'Failed to fetch driver home stats: $errorMessage',
    );
  }

  // Check HTTP status code
  if (res.statusCode != 200) {
    final errorMessage = responseMap?['message']?.toString() ?? 
                        responseMap?['data']?.toString() ?? 
                        res.body;
    throw Exception(
      'Failed to fetch driver home stats: '
      '${res.statusCode} ($errorMessage)',
    );
  }

  // Ensure response map is not null before parsing
  if (responseMap == null) {
    throw Exception('Invalid response: response body is null or empty');
  }

  final response = DriverHomeStatsResponse.fromJson(responseMap);

  // Return the nested data (model parsing will throw if null)
  return response.data.data; // inner "data"
}

/// Riverpod provider with retry logic for first load issues
final driverHomeStatsProvider = FutureProvider<DriverHomeStats>((ref) async {
  // Retry once if the first attempt fails (handles first load race conditions)
  try {
    return await _fetchDriverHomeStats(ref);
  } catch (e) {
    // If error contains "null", "id", "token", "auth" (common first load issues), retry once
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('null') || 
        errorStr.contains('id') || 
        errorStr.contains('token') ||
        errorStr.contains('auth') ||
        errorStr.contains('500')) {
      // Wait a bit before retry to allow token provider to refresh and backend to initialize
      await Future.delayed(const Duration(milliseconds: 500));
      // Invalidate token provider to force refresh before retry
      ref.invalidate(authTokenProvider);
      return await _fetchDriverHomeStats(ref);
    }
    rethrow;
  }
});
